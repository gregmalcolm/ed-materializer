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
  has_many :worlds
  has_many :stars
  has_many :basecamps
  has_many :surveys
  has_many :world_surveys
end
