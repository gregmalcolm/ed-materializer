class World < ActiveRecord::Base
  include Updater
  has_paper_trail

  after_save :update_system

  belongs_to :system
  has_many :basecamps, dependent: :destroy
  has_many :surveys, dependent:  :destroy
  has_one :world_survey, dependent: :destroy

  scope :by_system_id,  ->(system_id) { where(system_id: system_id) if system_id }
  scope :by_system,     ->(system_name) { where("UPPER(TRIM(system_name))=?", 
                                                system_name.to_s.upcase.strip ) if system_name }
  scope :by_world,      ->(world) { where("UPPER(TRIM(world))=?", 
                                                world.to_s.upcase.strip ) if world }
  scope :by_system_like, ->(system_name) { where("UPPER(TRIM(system_name)) like ?", 
                                                 "#{system_name.to_s.upcase.strip}%" ) if system_name }
  scope :by_world_like,  ->(world) { where("UPPER(TRIM(world)) like ?", 
                                           "#{world.to_s.upcase.strip}%" ) if world }
  scope :by_full_world_like, ->(full_world) { where("UPPER(TRIM(system_name)) || ' ' || UPPER(TRIM(world)) like ?", 
                                                    "#{full_world.to_s.upcase.strip}%" ) if full_world }

  scope :not_me, ->(id) { where.not(id: id) if id }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :updater, :system_name, :world, presence: true
  validate :key_fields_must_be_unique
  
  def has_children?
    world_survey.present? || basecamps.any? || surveys.any?
  end

  def parent_system
    System.by_system(system_name).first
  end

  private

  def key_fields_must_be_unique
    if World.by_system(self.system_name)
            .by_world(self.world)
            .not_me(self.id)
            .any?
      errors.add(:world, "has already been taken for this system")
    end
  end

  def update_system
    parent = system
    if parent.blank?
      parent = parent_system
      if parent.blank?
        attributes = { system: self.system_name, updater: self.updater }
        parent = System.create(attributes)
      end
    end
    if parent.system != self.system_name
      parent.update(system: self.system_name, updater: self.updater)
    end
    if parent.id && self.system_id != parent.id
      self.update(system_id: parent.id)
    end
  end
end

