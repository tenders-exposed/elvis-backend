class Search::AutocompleteSearch
  attr_accessor :request, :result

  def initialize(text, max_suggestions=10)
    @request = {
      size: max_suggestions,
      body: {
        query: {
          match: {
            name: text
          }
        }
      }
    }
  end

  def search
    @result = request["hits"]["hits"].map{|result| result["_source"]}
  rescue => e
    return e
  end

  def count
    request["hits"]["total"]
  rescue => e
    return e
  end

  def request
    client = Elasticsearch::Client.new(host: Mongoid::Elasticsearch.client_options[:host])
    client.search(index: 'autocomplete', **@request)
  end
end
