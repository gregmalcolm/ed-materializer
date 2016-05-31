class Star < ActiveRecord::Base
  include Updater
  has_paper_trail
  
  after_save :update_system
  
  belongs_to :system
  
  scope :by_system_id,  ->(system_id) { where(system_id: system_id) if system_id }
  scope :by_system,     ->(system_name){ where("UPPER(TRIM(system_name))=?", 
                                               system_name.to_s.upcase.strip ) if system_name }
  scope :by_star,       ->(star)    { where("COALESCE(UPPER(TRIM(star)),'')=?", star.to_s.upcase.strip ) if star }
  scope :by_full_star_like, ->(full_star) { where("UPPER(TRIM(system_name)) || ' ' || UPPER(TRIM(star)) like ?", 
                                                  "#{full_star.to_s.upcase.strip}%" ) if full_star }

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

