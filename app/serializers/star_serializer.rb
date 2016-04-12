class StarSerializer < ActiveModel::Serializer
  attribute  :id
  attribute  :system_name, key: :system
  attributes :updater,
             :star,
             :spectral_class,
             :spectral_subclass,
             :solar_mass,
             :solar_radius,
             :surface_temp,
             :star_age,
             :orbit_period,
             :arrival_point,
             :luminosity,
             :notes,
             :image_url,
             :updaters,
             :creator,
             :updated_at,
             :created_at
end
