class BasecampSerializer < ActiveModel::Serializer
  attributes :id,
             :world_id,
             :updater,
             :name,
             :description,
             :landing_zone_terrain,
             :terrain_hue_1,
             :terrain_hue_2,
             :terrain_hue_3,
             :landing_zone_lat,
             :landing_zone_lon,
             :notes,
             :image_url,
             :updated_at,
             :created_at
end
