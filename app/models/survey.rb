class Survey < ActiveRecord::Base
  has_paper_trail
  
  after_initialize :default_values  
  before_validation :update_system_id
  
  belongs_to :world
  belongs_to :basecamp
  belongs_to :system
  delegate :world, :to => :basecamp, :allow_nil => true

  scope :by_world_id, ->(world_id) { where(world_id: world_id) if world_id }
  scope :by_basecamp_id, ->(basecamp_id) { where(basecamp_id: basecamp_id) if basecamp_id }
  scope :by_commander, ->(commander) { where("UPPER(TRIM(commander))=?", commander.to_s.upcase.strip ) if commander }
  scope :by_resource,  ->(resource)  { where("COALESCE(UPPER(TRIM(resource)), '')=?", resource.to_s.upcase.strip ) if resource }

  scope :not_me, ->(id) { where.not(id: id) if id }

  scope :updated_before, ->(time) { where("updated_at<?", time ) if Time.parse(time) rescue false }
  scope :updated_after,  ->(time) { where("updated_at>?", time ) if Time.parse(time) rescue false }

  validates :commander, :world, :resource, presence: true

  private

  def default_values
    self.resource ||= "AGGREGATED"
  end
  
  def update_system_id
    if self.system_id.blank? and self.world
      self.system_id = self.world.system_id if self.world
    end
  end
end

