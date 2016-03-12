class WorldSurvey < ActiveRecord::Base
  include Updater
  has_paper_trail

  belongs_to :world

  scope :by_world_id,   ->(world_id) { where(world_id: world_id) if world_id }

  scope :not_me, ->(id) { where.not(id: id) if id }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :updater, :world, presence: true
  validate :key_fields_must_be_unique

  private

  def key_fields_must_be_unique
    if WorldSurvey.by_world_id(self.world_id)
                  .not_me(self.id)
                  .any?
      errors.add(:world_survey, "has already been taken for this name for this world")
    end
  end
end

