module Api
  module V1
    class ApiController < ApplicationController
      include Elastic

      def render_error(message)
        render :json => {:error => message}.to_json, :status => 422
      end

    end

    module Elastic

      define_method(:search_json_response) do |count: nil , results: []|
        response = {search: {count: count, results: results.to_a}}
      end

    end
    
  end
end
