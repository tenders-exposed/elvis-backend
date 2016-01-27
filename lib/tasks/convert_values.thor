class ConvertValues < Thor

  desc "to euro", "Convert all values in Euro"
  def to_euro
    aprox_conv_rates = aprox_rates
    Contract.not_in(:'award.value.currency' => 'EUR').order_by{|t| [date.x_year,
      date.x_month, date.x_day, value.currency]}.each do |doc|
        value = doc.award.value
        date = doc.award.date
        full_date = convert_date(date.x_year, date.x_month, date.x_day)
        if value.amount > 0.0 && value.x_amount_eur == 0.0
          if full_date
            currency = third_party_request(full_date, value.currency)
            value_euro = currency * value.amount
          else
            currency = aprox_conv_rates[date.x_year.to_s][value.currency].to_f
            value_euro = currency * value.amount
          end
          doc.award.value.update_attributes!({x_amount_eur: value_euro})
        end
    end
  end

  no_commands{

    def third_party_request date, currency
      link = "http://currencies.apps.grandtrunk.net/getrate/#{date}/EUR/#{currency}"
      response = HTTParty.get(link)
      return response.to_f
    end

    def convert_date year, month, day
      if (year && month && day) != 0
        m = month < 10 ? month.to_s.prepend('0') : month.to_s
        d = day < 10 ? day.to_s.prepend('0') : day.to_s
        date = [year.to_s, m, d].join('-')
      else
        nil
      end
    end

    def conversion_rates year
      link = "http://raw.githubusercontent.com/tenders-exposed/data_sources/" \
              "master/#{year}_euro_conversion_rates.json"
      rates = HTTParty.get(link).body
      JSON.parse(rates)
    end

    def aprox_rates
      ["2008", "2009", "2010"].inject({}) do |memo, year|
        memo[year] = conversion_rates(year)
        memo
      end
    end

  }
end
