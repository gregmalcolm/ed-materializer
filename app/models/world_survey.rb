class WorldSurvey < ActiveRecord::Base
  has_paper_trail

  scope :by_system,    ->(system)    { where("UPPER(TRIM(system))=?", system.to_s.upcase.strip ) if system }
  scope :by_commander, ->(commander) { where("UPPER(TRIM(commander))=?", commander.to_s.upcase.strip ) if commander }
  scope :by_worl<F6>,     ->(world)     { where("UPPER(TRIM(world))=?", world.to_s.upcase.strip ) if world }

  scope :not_me, ->(id) { where.not(id: id) if id }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :commander, :system, :world, presence: true
  validate :key_fields_must_be_unique

  private

  def key_fields_must_be_unique
    if WorldSurvey.by_commander(self.commander)
                  .by_system(self.system)
                  .by_world(self.world)
                  .not_me(self.id)
                  .any?
      errors.add(:world, "has already been taken for this system and commander")
    end
  end
end

