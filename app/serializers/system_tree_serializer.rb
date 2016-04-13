class SystemTreeSerializer < SystemSerializer
  has_many :worlds
  has_many :stars
  has_many :world_surveys
  has_many :basecamps
  has_many :surveys
end
