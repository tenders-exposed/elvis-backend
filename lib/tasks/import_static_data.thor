class ImportStaticData < Thor
  require 'json'

  desc "store redis", "Store country names in Redis"
  def store_redis
    countries_link = "http://raw.githubusercontent.com/tenders-exposed/data_sources/" \
                     "master/countrynames_iso2_correspondence.json"
    cpvs_link = "http://raw.githubusercontent.com/tenders-exposed/data_sources/master/" \
                "cpvs_with_names.json"
    store_collection("countries", countries_link)
    store_collection("cpvs", cpvs_link )
  end

  no_commands {

    def store_collection(collection_name, data_link)
      collection = Redis::HashKey.new(collection_name)
      data = HTTParty.get(data_link).body
      collection.bulk_set(JSON.parse(data))
    end

  }
end
