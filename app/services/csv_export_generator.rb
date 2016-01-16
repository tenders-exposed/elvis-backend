class CsvExportGenerator
  require 'csv'

  attr_accessor :contracts

  def initialize(query)
    @contracts = Search::ContractSearch.new(query).search
  end

  def generate_csv(file_name)
    CSV.open("#{Rails.root}/tmp/#{file_name}", "wb") do |csv|
      csv.add_row header
      @contracts.each do |contract|
        flat_contract = flatten_hash(contract.as_document)
        values = flat_contract.values
        # # .except(*foo_attributes)
        csv.add_row values
      end
    end
  end

  def header
    build_header(flatten_hash(@contracts.first.as_document).keys)
  end

  def flatten_hash(hash)
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        flatten_hash(v).map do |h_k, h_v|
          h["#{k}.#{h_k}"] = h_v
        end
      elsif v.is_a? Array
        v.each do |el|
          if el.is_a? Hash
            flatten_hash(el).map do |h_k, h_v|
              h["#{k}.#{h_k}"] = h_v
            end
          else
            h[k] = v
          end
        end
      else
        h[k] = v
      end
    end
  end

  def build_header attributes
    attributes.map do |value|
      objects = value.split(".")
      objects.each{|s| s.gsub! 'procuring_entity', 'procuringEntity' }
      last = objects.pop
      if objects.empty?
        last
      else
        [objects.join("/"), last].join(".")
      end
    end
  end

end
