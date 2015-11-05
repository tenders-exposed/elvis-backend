class CsvExportGenerator
  require 'csv'

  def self.to_csv(attributes = column_names, options = {})

  CSV.generate(options) do |csv|
    csv.add_row foo_attributes + bar_attributes

      all.each do |foo|

        values = foo.attributes.slice(*foo_attributes).values

        if foo.contact_details
          values += foo.contact_details.attributes.slice(*bar_attributes).values
        end

        csv.add_row values
      end
    end
  end

  
end
