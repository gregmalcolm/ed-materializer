class Star < ActiveRecord::Base
  include Updater
  has_paper_trail
  
  before_save :update_system
  
  scope :by_system,     ->(system_name){ where("UPPER(TRIM(system_name))=?", 
                                               system_name.to_s.upcase.strip ) if system_name }
  scope :by_star,       ->(star)    { where("COALESCE(UPPER(TRIM(star)),'')=?", star.to_s.upcase.strip ) if star }

  scope :not_me, ->(id) { where.not(id: id) if id }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :updater, :system_name, presence: true
  validate :key_fields_must_be_unique
  
  def parent_system
    System.by_system(system_name).first
  end

  private
  
  def key_fields_must_be_unique
    if Star.by_system(self.system_name)
           .by_star(self.star)
           .not_me(self.id)
           .any?
      errors.add(:star, "has already been taken for this system")
    end
  end
  
  def update_system
    parent = parent_system
    attributes = { system: self.system_name, updater: self.updater }
    if parent
      parent.update(attributes)
    else
      System.create(attributes)
    end
  end
end

