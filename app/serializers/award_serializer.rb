class AwardSerializer < ActiveModel::Serializer
  attributes :title, :description

  # has_one :value, embed: :ids, embed_in_root: true
  has_one :date, embed: :objects, embed_in_root: true
  # belongs_to :document
end
