module Indices
  class Base

    attr_reader :mapping, :client, :index

    def initialize
      @mapping = {}
      @client = Elasticsearch::Client.new(host: Mongoid::Elasticsearch.client_options[:host])
    end

    def index_name
      self.mapping[:index_name]
    end

    def index_settings
      self.mapping[:index_options][:settings]
    end

    def index_mappings
      self.mapping[:index_options][:mappings]
    end

    def update_index
      @index = Elasticsearch::API::Indices::IndicesClient.new(@client)
      index_options = {
        index: self.index_name,
        body: self.index_settings,
      }
      @index.create(index_options) unless @index.exists(index_options)
    end

    def update_type_mappings
      self.update_index
      self.index_mappings.each do |type, properties|
        type_mappings = {
          index: self.index_name,
          type: type,
          body: {},
        }
        type_mappings[:body][type] = properties
        @index.put_mapping(type_mappings)
      end
    end

  end
end
