# Put here because of https://github.com/rs-pro/mongoid-elasticsearch/issues/11
Mongoid::Elasticsearch.autocreate_indexes = false
Mongoid::Elasticsearch.client_options[:host] = ENV["ES_HOST"] || 'localhost'
