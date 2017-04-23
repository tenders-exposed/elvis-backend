class ImportStaticData < Thor
  require 'json'

  desc "store redis", "Store country names in Redis"
  def store_redis
    store_countries
    store_cpvs
  end

  no_commands {

    def store_countries
      countries_link = "http://raw.githubusercontent.com/tenders-exposed/data_sources/" \
                       "master/countrynames_iso2_correspondence.json"
      data = HTTParty.get(countries_link).body
      collection = Redis::HashKey.new('countries')
      collection.del
      collection.bulk_set(JSON.parse(data))
    end

    def store_cpvs
      cpvs_link = "http://raw.githubusercontent.com/tenders-exposed/data_sources/master/" \
                  "cpv_codes.json"
      data = HTTParty.get(cpvs_link).body
      collection = Redis::HashKey.new('cpvs', marshal: true)
      collection.del
      JSON.parse(data).each{|cpv_code| collection[cpv_code['code']] = cpv_code}
    end

  }
end
