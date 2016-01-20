module Api
  module V1
    class ApiController < ApplicationController
      acts_as_token_authentication_handler_for User, fallback: :none

      def render_error(message)
        render json: {error: message} , status: 422
      end
    end
  end
end
