class World < ActiveRecord::Base
  include Updater
  has_paper_trail

  has_many :basecamps, dependent: :destroy
  has_one :world_survey, dependent: :destroy
  has_many :site_surveys, through: :basecamps

  scope :by_system,     ->(system)  { where("UPPER(TRIM(system))=?", system.to_s.upcase.strip ) if system }
  scope :by_world,      ->(world)   { where("UPPER(TRIM(world))=?", world.to_s.upcase.strip ) if world }

  scope :not_me, ->(id) { where.not(id: id) if id }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :updater, :system, :world, presence: true
  validate :key_fields_must_be_unique
  
  def has_children?
    world_survey.present? || basecamps.any?
  end

  private

  def key_fields_must_be_unique
    if World.by_system(self.system)
            .by_world(self.world)
            .not_me(self.id)
            .any?
      errors.add(:world, "has already been taken for this system")
    end
  end
end

