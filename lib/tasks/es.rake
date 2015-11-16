task :reindex => ['es:require'] do
  Mongoid::Elasticsearch.registered_models.each do |model_name|
    pb = nil
    model_name.constantize.es.index_all do |steps, step|
      pb = ProgressBar.create(title: model_name, total: steps, format: '%t: %p%% %a |%b>%i| %E') if pb.nil?
      pb.increment
    end
  end
end
