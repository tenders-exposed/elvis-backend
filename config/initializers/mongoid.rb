module Mongoid
  module Document

    include ActiveModel::SerializerSupport

    def serializable_hash(options = nil)
      h = super(options)
      h['id'] = h.delete('_id') if(h.has_key?('_id'))
      h
    end

  end
end

Mongoid::Criteria.delegate(:active_model_serializer, :to => :to_a)
