class Search::CpvSearch
  require 'elasticsearch'

  attr_accessor :client, :list
  def initialize
    @client = Elasticsearch::Client.new(log: true)
  end

  def get_suggestions(code = nil)
    if code
      criteria = { match: {"ORIGINAL_CODE"=>code.to_s}}
    else
      criteria = { match_all: {}}
    end
    @list = @client.search index: 'cpvs', body: {
      query:{
        function_score: {
          query: criteria,
        functions: [
            {
              script_score: {
                 script: {lang:"groovy", file:"boost_by_category"}
              }
            }
          ]
        }
      },
      sort: [
        "_score",
        { "REAL_CODE" => {order: "asc"}}
      ]
    }
    parse_response
  end


  def parse_response
    result = @list.deep_symbolize_keys![:hits].slice(:total, :hits)
    result[:hits].map!{|hash| hash.slice(:_score,:_source)}
    result[:hits].map!{|hash| hash[:_source].slice(:ORIGINAL_CODE, :NAME).transform_keys{|k| k.downcase}}
    result
  end

end
