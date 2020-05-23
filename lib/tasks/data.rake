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
end
