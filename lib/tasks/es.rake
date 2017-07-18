namespace :es do
  task :update_indices => ['es:require'] do |task, args|
    registered_models = Mongoid::Elasticsearch.registered_models
    models_to_index = args.extras
    unless models_to_index.empty?
      indices = registered_models & models_to_index
      p 'The models you passed are not registered indices' if indices.empty?
    else
      models_to_index = registered_models
    end

    models_to_index.each do |model_name|
      # Create the index if it doesn't exist
      model = model_name.constantize
      es_indices = model.es.client.indices
      index_options = {
        index: model.es.index.name,
        body: model.es.index.options[:settings]
      }
      es_indices.create(index_options) unless es_indices.exists(index_options)

      # Update the index mapping for this model's type
      model_mapping = index_options.merge(
        type: model.es.index.type,
        body: model.es.index.options[:mappings]
      )
      es_indices.put_mapping(model_mapping)

      # Index the data in the collection
      cursor = model.asc(:id)
      step_size = 1000
      steps = (cursor.count / step_size) + 1
      last_id = nil
      pb = nil
      steps.times do |step|
         if last_id
           docs = cursor.gt(id: last_id).limit(step_size).to_a
         else
           docs = cursor.limit(step_size).to_a
         end
         last_id = docs.last.try(:id)
         docs = docs.map do |obj|
           if obj.es_index?
             { index: {data: obj.as_indexed_json}.merge(_id: obj.id.to_s) }
           else
             nil
           end
         end.reject { |obj| obj.nil? }
         model_data = model_mapping.merge({body: docs})
         model.es.client.bulk(model_data)
         pb = ProgressBar.create(title: model_name, total: steps, format: '%t: %p%% %a |%b>%i| %E') if pb.nil?
         pb.increment
      end
    end
  end
end
