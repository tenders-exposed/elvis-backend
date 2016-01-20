module SearchResponseFormatter
  extend ActiveSupport::Concern

  define_method(:search_json_response) do |count: nil , results: []|
    response = {search: {count: count, results: results.to_a}}
  end

end
