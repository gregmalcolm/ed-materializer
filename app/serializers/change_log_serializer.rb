class ChangeLogSerializer < ActiveModel::Serializer
  attributes :id,
             :item_type,
             :item_id,
             :event,
             :object,
             :created_at
end
