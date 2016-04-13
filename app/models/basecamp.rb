class Basecamp < ActiveRecord::Base
  include Updater
  has_paper_trail

  belongs_to :world
  has_many :surveys, dependent: :destroy

  scope :by_world_id,   ->(world_id) { where(world_id: world_id) if world_id }
  scope :by_name,       ->(name)  { where("UPPER(TRIM(name))=?", name.to_s.upcase.strip ) if name }

  scope :not_me, ->(id) { where.not(id: id) if id }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :updater, :name, :world, presence: true
  validate :key_fields_must_be_unique

  def has_children?
    surveys.any?
  end

  private

  def key_fields_must_be_unique
    if Basecamp.by_world_id(self.world_id)
               .by_name(self.name)
               .not_me(self.id)
               .any?
      errors.add(:basecamp, "has already been taken for this name for this world")
    end
  end
end

