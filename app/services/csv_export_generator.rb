class CsvExportGenerator
  include Enumerable
  require 'securerandom'
  require 'open3'
  require 'csv'
  require 'yajl'

  attr_accessor :contracts

  def initialize(query)
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
      while row=stdout.gets do
        hash = Yajl::Parser.new.parse(row)
        yield line(hash)
      end
    end
    File.delete(file_path)
  end

  def header
    CSV.generate_line(build_header(flatten_hash(@contracts.first.as_document).keys))
  end

  def line(row)
    CSV.generate_line(flatten_hash(row).values)
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
