class ValueConverter < Thor
  include HTTParty
  include Json

  desc "Convert all values in Euro"
  def convert_in_euro
    Award.not_in(:'value.currency' => 'EUR').order_by{|t| [date.x_year, date.x_month,
      date.x_day, value.currency]}.each do |a|
        
    end
  end

  no_commands{

  def request date, currency

  end
end
