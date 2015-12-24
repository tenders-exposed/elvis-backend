class Api::V1::ApiController < ApplicationController
  require 'api/error'

  define_method(:search_json_response) do |count: nil , results: []|
    response = {search: {count: count, results: results.to_a}}
  end
end
