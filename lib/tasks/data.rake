require 'net/http'
require 'csv'

namespace :data do
  desc "Fetch municipal level case data from RIVM"
  task :fetch, [:force] => :environment do |t, args|
    @domain = "data.rivm.nl"
    @path = "/covid-19/COVID-19_aantallen_gemeente_cumulatief.csv"

    @last_fetch_day = Case.maximum(:day) || Date.new(2020,3,2)
    if @last_fetch_day == Date.today
      puts "Already fetched todays records"
      exit 0
    end

    # Check if there are fresh records:
    Net::HTTP.start(@domain, :use_ssl => true) do |http|
      # Fetch header and check Last-Modified
      response = http.request_head(@path)
      @last_modified = Time.parse(response["Last-Modified"])
    end

    if @last_modified.to_date < Date.today
      puts "Todays records not yet available"
      exit 0 unless args.force == "true"
      puts "Processing anyway..."
    end

    # Fetch CSV
    Net::HTTP.start(@domain, :use_ssl => true) do |http|
      puts "Downloading CSV..."
      response = http.request_get(@path)
      puts "Parsing CSV..."
      Time.zone = "Europe/Amsterdam"
      @csv = CSV.parse(response.body, headers: true, encoding: Encoding::UTF_8, col_sep: "\;", converters: [->(v) { Time.strptime(v, '%Y-%m-%d %I:%M:%S') rescue v }, :numeric])
    end

    puts "Processing records..."
    @csv.each do |row|
      # Ignore province rows at the end
      next if row["Municipality_code"].nil?

      # Check if we already have this municipality
      municipality = Municipality.create_with(
        province: Province.find_by(name: row["Province"]),
        name: row["Municipality_name"]
      ).find_or_create_by(cbs_id: row["Municipality_code"])

      # Record cases
      c = Case.find_or_create_by(
        municipality: municipality,
        day: row["Date_of_report"].to_date.to_time(:utc) # ignore RIVM reporting time
      )
      # Set or update info, mark for processing if new or updated
      c.reports = row["Total_reported"]
      c.hospitalizations = row["Hospital_admission"]
      c.deaths = row["Deceased"]
      c.processed = c.processed && !c.changed?
      begin
        c.save!
      rescue ActiveRecord::RecordInvalid => e
        pp row
        throw c.errors
      end
    end
  end

  desc "Process existing data"
  task :process, [:force] => :environment do |t, args|
    # Find first day with unprocessed cases. If existing entries were updated
    # on any given day, we need to recalculate the daily difference for all
    # subsequent days.
    start = Case.where(processed: false).where("day >= ?", CrushCurve::START_DATE + 1.day).order(day: :asc).first
    if start.nil?
      puts "No new or modified cases"
      if args.force == "true"
        start = Case.where("day >= ?", CrushCurve::START_DATE + 1.day).order(day: :asc).first
      else
        exit 0
      end
    end

    # Calculate daily stats
    the_day = nil
    Case.where("day >= ?", start.day.to_date).order(day: :asc).each do |c|
      puts "#{ c.day.to_date }..." if the_day != c.day
      the_day = c.day
      # If no reports today, assume 0 new cases
      if c.reports.nil?
        c.update new_reports: 0, processed: true
        next
      end

      reference_day = c

      loop do
        reference_day = reference_day.yesterday
        if reference_day.nil?
          throw "Found 1+ day gap in data on #{ c.day.to_date } in #{ c.municipality.name } (#{ c.municipality.cbs_id }), bailing out"
        end

        if !reference_day.reports.nil?
          # Assume new cases are recent (alternative: take average per day)
          new_reports = c.reports - reference_day.reports
          c.update new_reports: new_reports, processed: true
          break
        end
      end
    end

    # Sort provinces by severity on peak date
    Province.all.collect{|p| [p.cases.where('date(day) = ?', (CrushCurve::PEAK_DATE + 1.day).to_date).sum(:reports), p]}.sort.reverse.each_with_index do |p,i|
      p[1].update position: i
    end

    # Sort municipalities by severity on reference date
    Municipality.all.collect{|p| [p.cases.where('date(day) = ?', (CrushCurve::PEAK_DATE + 1.day).to_date).sum(:reports), p]}.sort.reverse.each_with_index do |p,i|
      p[1].update position: i
    end

    Case.expire_cache
  end

  desc "Send notifications"
  task :notify, [:force] => :environment do |t, args|
    Rpush.apns_feedback

    # Good news:
    Case.where(notified: false, new_reports: 0).where("date(day) = ?", Time.now.to_date).each do |c|
      c.update notified: true
      # Only notify about zero cases if there were more than zero cases yesterday:
      if c.yesterday.new_reports > 0
        c.municipality.subscriptions.each do |s|
          s.notify(
            "Geen corona in #{ c.municipality.name }",
            "Er zijn geen positieve testuitslagen in #{ c.municipality.name } gemeld bij het RIVM afgelopen etmaal. U krijgt bericht als dat verandert.",
            [c.municipality.province.slug]
          )
        end
      end
    end

    # Bad news:
    Case.where(notified: false).where("date(day) = ? AND new_reports > 0", Time.now.to_date).each do |c|
      c.update notified: true
      c.municipality.subscriptions.each do |s|
        s.notify(
          "Corona in #{ c.municipality.name }",
          "Er zijn #{ c.new_reports } positieve testuitslagen in #{ c.municipality.name } gemeld bij het RIVM afgelopen etmaal",
          [c.municipality.province.slug]
        )
      end
    end

    Rpush.push
  end

end
