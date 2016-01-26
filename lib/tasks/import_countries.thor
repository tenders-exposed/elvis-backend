class ImportCountries < Thor
  require 'json'

  desc "store redis", "Store country names in Redis"
  def store_redis
    @countries = Redis::HashKey.new('countries')
    link = "http://raw.githubusercontent.com/tenders-exposed/data_sources/" \
            "master/countrynames_iso2_correspondence.json"
    country_list = HTTParty.get(link).body
    @countries.bulk_set(JSON.parse(country_list))
  end

end
