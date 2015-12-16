class Elastic::CountriesController < ApplicationController

  def index
    countries = AvailableCountries.new().with_name
    render json: countries
  end
end
