module Api
  module V1
    class ApiController < ActionController::API
      include Contracts
      acts_as_token_authentication_handler_for User, fallback: :none

      def render_error(message)
        render json: {error: message} , status: 422
      end

    end

    module Contracts

      define_method(:search_json_response) do |count: nil , results: []|
        response = {search: {count: count, results: results.to_a}}
      end

    end

  end
end
