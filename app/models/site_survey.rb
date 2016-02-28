class SiteSurvey < ActiveRecord::Base
  has_paper_trail
  
  after_initialize :default_values  
  belongs_to :basecamp

  scope :by_basecamp_id, ->(basecamp_id) { where(basecamp_id: basecamp_id) if basecamp_id }
  scope :by_commander, ->(commander) { where("UPPER(TRIM(commander))=?", commander.to_s.upcase.strip ) if commander }
  scope :by_resource,  ->(resource)  { where("COALESCE(UPPER(TRIM(resource)), '')=?", resource.to_s.upcase.strip ) if resource }

  scope :not_me, ->(id) { where.not(id: id) if id }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :commander, :basecamp, :resource, presence: true

  private

  def default_values
    self.resource ||= "AGGREGATED"
  end
end

