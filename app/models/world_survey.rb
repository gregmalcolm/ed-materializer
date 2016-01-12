class WorldSurvey < ActiveRecord::Base
  scope :by_system,    ->(system)    { where("UPPER(TRIM(system)=?", system.to_s.upcase.strip ) if system }
  scope :by_commander, ->(commander) { where("UPPER(TRIM(commander))=?", commander.to_s.upcase.strip ) if commander }
  scope :by_world,     ->(world)     { where("UPPER(TRIM(world))=?", world.to_s.upcase.strip ) if world }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :commander, uniqueness: { scope: [:system, :world] }
end

