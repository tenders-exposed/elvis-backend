module Api
  module V1
    class ApiController < ApplicationController

      def render_error(message)
        render json: {error: message} , status: 422
      end
      
    end
  end
end
