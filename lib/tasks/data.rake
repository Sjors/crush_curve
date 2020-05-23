namespace :data do
  desc "Fetch the latest data"
  task fetch: :environment do
    @service = Geoservice::MapService.new(url: "https://services.arcgis.com/nSZVuSZjHpEZZbRo/arcgis/rest/services/Coronavirus_RIVM_vlakken_historie/FeatureServer")
    @last_fetched = Case.maximum(:esri_id)

    loop do
      puts "Fetch new records after #{ @last_fetched }..."
      query = @service.query(0, {returnGeometry: false, where: "ObjectId > #{ @last_fetched }"})

      if query["features"].count == 0
        puts "No new records"
        break
      end

      query["features"].each do |feature|
        attributes = feature["attributes"]

        # Check if we already have this municipality
        municipality = Municipality.create_with(
          province: Province.find_by(cbs_n: attributes["Provincienummer"]),
          name: attributes["Gemeentenaam"],
          inhabitants: attributes["Bevolkingsaantal"],
        ).find_or_create_by(cbs_id: attributes["Gemeentecode"])

        # Record cases
        Case.create(
          esri_id: attributes["ObjectId"],
          municipality: municipality,
          day: Time.at(attributes["Datum"] / 1000),
          reports: attributes["Meldingen"],
          hospitalizations: attributes["Ziekenhuisopnamen"],
          deaths: attributes["Overleden"]
        )

        @last_fetched = attributes["ObjectId"]
      end

      break if !query["exceededTransferLimit"]
    end
  end

  desc "Process existing data"
  task process: :environment do
    # Calculate daily stats
    the_day = nil
    Case.where("day >= ?", Date.new(2020,4,9)).order(day: :asc).each do |c|
      puts "#{ c.day.to_date }..." if the_day != c.day
      the_day = c.day
      # If no reports today, assume 0 new cases
      if c.reports.nil?
        c.update new_reports: 0
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
          if new_reports < 0
            # Ignore corrections
            new_reports = 0
          end
          c.update new_reports: new_reports
          break
        end
      end
    end

    # Sort provinces by severity on reference date
    Province.all.collect{|p| [p.cases.where('date(day) = ?', Date.new(2020,4,9).to_date).sum(:reports), p]}.sort.reverse.each_with_index do |p,i|
      p[1].update position: i
    end
  end
end
