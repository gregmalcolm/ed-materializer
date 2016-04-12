class SystemSerializer < ActiveModel::Serializer
  attributes :id,
             :system,
             :updater,
             :x,
             :y,
             :z,
             :poi_name,
             :notes,
             :image_url,
             :tags,
             :updaters,
             :creator,
             :updated_at,
             :created_at
end
