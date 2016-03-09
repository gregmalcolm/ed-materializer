class Star < ActiveRecord::Base
  include Updater
  has_paper_trail
  
  scope :by_system,     ->(system)  { where("UPPER(TRIM(system))=?", system.to_s.upcase.strip ) if system }
  scope :by_star,       ->(star)    { where("COALESCE(UPPER(TRIM(star)),'')=?", star.to_s.upcase.strip ) if star }

  scope :not_me, ->(id) { where.not(id: id) if id }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :updater, :system, presence: true
  validate :key_fields_must_be_unique

  private
  
  def key_fields_must_be_unique
    if Star.by_system(self.system)
           .by_star(self.star)
           .not_me(self.id)
           .any?
      errors.add(:star, "has already been taken for this system")
    end
  end
end

