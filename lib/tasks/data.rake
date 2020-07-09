namespace :data do
  desc "Fetch the latest data"
  task :fetch, [:force] => :environment do |t, args|
    @service = Geoservice::MapService.new(url: "https://services.arcgis.com/nSZVuSZjHpEZZbRo/arcgis/rest/services/Coronavirus_RIVM_vlakken_historie/FeatureServer")
    @last_fetch_day = Case.maximum(:day) || Date.new(2020,3,2)

    query_params = {
      returnGeometry: false
    }

    # Check if there are fresh records:
    query = @service.query(0, query_params.merge({
      where: "Datum > DATE '#{ @last_fetch_day.strftime("%Y-%m-%d") }'",
      returnCountOnly: true
    }))

    if query.nil?
      puts "No response"
      exit 0
    end

    if query["error"]
      throw query
    end

    if query["count"] == 0
      puts "No new records"
      exit 0 unless args.force == "true"
    end

    # If there are any new records, re-download the full dataset, because there
    # may be updates. Skip records before CrushCurve::START_DATE, except the first
    # time.
    @last_fetch_day = CrushCurve::START_DATE if Case.count > 0
    @last_fetched = 0
    loop do
      puts "Fetch new records after #{ @last_fetched }..."
      query = @service.query(0, query_params.merge({
        where: "ObjectId > #{ @last_fetched } AND Datum >= DATE '#{ @last_fetch_day.strftime("%Y-%m-%d") }'"
      }))

      query["features"].each do |feature|
        attributes = feature["attributes"]

        # Check if we already have this municipality
        municipality = Municipality.create_with(
          province: Province.find_by(cbs_n: attributes["Provincienummer"]),
          name: attributes["Gemeentenaam"],
          inhabitants: attributes["Bevolkingsaantal"],
        ).find_or_create_by(cbs_id: attributes["Gemeentecode"])

        # Record cases
        c = Case.find_or_create_by(
          municipality: municipality,
          day: Time.at(attributes["Datum"] / 1000),
        )
        # Set or update info, mark for processing if new or updated
        c.reports = attributes["Meldingen"]
        c.hospitalizations = attributes["Ziekenhuisopnamen"]
        c.deaths = attributes["Overleden"]
        c.processed = c.processed && !c.changed?
        begin
          c.save!
        rescue ActiveRecord::RecordInvalid => e
          pp attributes
          throw c.errors
        end

        @last_fetched = attributes["ObjectId"]
      end

      break if !query["exceededTransferLimit"]
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

    # Sort provinces by severity on reference date
    Province.all.collect{|p| [p.cases.where('date(day) = ?', (CrushCurve::START_DATE + 1.day).to_date).sum(:reports), p]}.sort.reverse.each_with_index do |p,i|
      p[1].update position: i
    end

    # Sort municipalities by severity on reference date
    Municipality.all.collect{|p| [p.cases.where('date(day) = ?', (CrushCurve::START_DATE + 1.day).to_date).sum(:reports), p]}.sort.reverse.each_with_index do |p,i|
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
