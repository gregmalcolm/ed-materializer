class StarSerializer < ActiveModel::Serializer
  attributes :id,
             :system,
             :updater,
             :star,
             :star_type,
             :subclass,
             :solar_mass,
             :solar_radius,
             :surface_temp,
             :star_age,
             :orbit_period,
             :arrival_point,
             :luminosity,
             :note,
             :updated_at,
             :created_at
end
