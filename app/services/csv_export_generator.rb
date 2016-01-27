class CsvExportGenerator
  include Enumerable
  require 'securerandom'
  require 'open3'
  require 'csv'
  require 'yajl'

  attr_reader :contracts

  def initialize query
    @contracts = Search::ContractSearch.new(query).search
  end

  def each
    yield header

    generate_csv do |row|
      yield row
    end
  end

  def generate_csv
    file_name = SecureRandom.hex + '.json'
    file_path = "#{Rails.root}/tmp/#{file_name}"
    query_file = File.open(file_path, 'w+') {|f| f.write(@contracts.selector.to_json) }
    command = "mongoexport --db #{Mongoid.default_client.options[:database]}" \
     " --collection contracts --queryFile \"#{file_path}\" "
    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
      while row = stdout.gets do
        hash = Yajl::Parser.new.parse(row)
        yield line(hash)
      end
    end
    File.delete(file_path)
  end

  def header
    # Both as_document and to_json required to get all the fields as string
    sample_row = Yajl::Parser.new.parse(@contracts.first.as_document.to_json)
    attributes = format_contract(sample_row).keys
    CSV.generate_line(build_header(attributes))
  end

  def line contract_hash
    CSV.generate_line(format_contract(contract_hash).values)
  end

  def build_header attributes
    attributes.map do |value|
      objects = value.split(".")
      last = objects.pop
      if objects.empty?
        last
      else
        [objects.join("/"), last].join(".")
      end
    end
  end

  def format_contract document
    flat_contract = flatten_hash(document)
    # Remove ids nested more than 2 levels
    flat_contract.delete_if do |k|
      (k.include? "_id.$oid") && (!k.match(/^(([^\.]+\.){0,2}[^\.]+)$/))
    end
    flat_contract.each_with_object({}) do |(k, v), memo|
      # For more info on this magic see: http://stackoverflow.com/questions/35039601/apply-modification-only-to-substring-in-ruby/35040853#35040853
      new_k = k.gsub("_id.$oid","id").gsub(/(?<!\bx)_(\w)/) { $1.capitalize }
      memo[new_k] = (new_k == "x_CPV") ? v.join(";") : v.to_s
    end
  end

  def flatten_hash hash
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

end
