class SystemTreeSerializer < SystemSerializer
  has_many :worlds
  #has_many :stars
  #has_many :world_surveys
  #has_many :basecamps
  #has_many :surveys
  attribute :world_ids
  
  #def world_ids
    #object.worlds.pluck(:id)
  #end

  #def as_json
    
  #end
end
