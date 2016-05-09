class System < ActiveRecord::Base
  include Updater
  has_paper_trail
  
  has_many :stars
  has_many :worlds
  has_many :basecamps, through: :worlds
  has_many :world_surveys, through: :worlds
  has_many :surveys, through: :basecamps

  after_save :update_children_system_names

  scope :by_system, ->(system) { where("UPPER(TRIM(system))=?", system.to_s.upcase.strip ) if system }
  scope :by_query, ->(query) { where("UPPER(TRIM(system)) like ?", "%#{query.to_s.upcase.strip}%" ) if query }

  scope :not_me, ->(id) { where.not(id: id) if id }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :updater, :system, presence: true
  validate :key_fields_must_be_unique
  
  def has_children?
    World.by_system(self.system).any? || Star.by_system(self.system).any?
  end

  def worlds
    World.by_system(system)
  end
  
  def stars
    Star.by_system(system)
  end

  private
  
  def key_fields_must_be_unique
    if System.by_system(self.system)
             .not_me(self.id)
             .any?
      errors.add(:system, "name has already been taken for this system")
    end
  end
  
  def update_children_system_names
    if self.id
      Star.where(system_id: self.id)
          .where.not(system_name: self.system)
          .update_all(system_name: self.system)
      World.where(system_id: self.id)
           .where.not(system_name: self.system)
           .update_all(system_name: self.system)
    end
  end
end

