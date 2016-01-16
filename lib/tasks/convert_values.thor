class ConvertValues < Thor

  desc "to euro", "Convert all values in Euro"
  def to_euro
    Contract.not_in(:'award.value.currency' => 'EUR').order_by{|t| [date.x_year,
      date.x_month,date.x_day, value.currency]}.each do |doc|
        date = convert_date(doc.award.date.x_year, doc.award.date.x_month, doc.award.date.x_day)
        if date && doc.award.value.amount > 0.0 && doc.award.value.x_amountEur == 0.0
          currency = request(date,doc.award.value.currency)
          value_euro = currency * doc.award.value.amount
          doc.award.value.update_attributes!({x_amountEur: value_euro})
        end
    end
  end

  no_commands{

    def request date, currency
      link = "http://currencies.apps.grandtrunk.net/getrate/#{date}/EUR/#{currency}"
      response = HTTParty.get(link)
      return response.to_f
    end

    def convert_date year, month, day
      unless (year || month || day) == 0
        m = month < 10 ? month.to_s.prepend('0') : month.to_s
        d = day < 10 ? day.to_s.prepend('0') : day.to_s
        date = [year.to_s, m, d].join('-')
      end
    end
  }
end
