require "#{Rails.root}/app/indices/indices.rb"
include Indices

namespace :es do
  task :update_indices => ['es:require'] do |task, args|
    registered_indices = Indices.constants.select {|c| Indices.const_get(c).is_a?(Class)}
    registered_names = registered_indices.map(&:to_s).map(&:downcase).select{|name| name != 'base'}
    indices_to_update = args.extras.map(&:downcase)
    unless indices_to_update.empty?
      indices = registered_names & indices_to_update
      p 'The models you passed are not registered indices' if indices.empty?
    else
      indices_to_update = registered_names
    end

    indices_to_update.each do |index_name|
      class_name = index_name.camelize
      index_class = Indices.const_get(class_name)
      index = index_class.new()
      index.update_index
      index.update_type_mappings
      index.populate_index
    end
  end
end
