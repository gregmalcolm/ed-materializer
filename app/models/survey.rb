class Survey < ActiveRecord::Base
  has_paper_trail
  
  after_initialize :default_values  
  before_validation :update_system_id
  after_save :update_world_surveys
  after_destroy :update_world_surveys
  
  belongs_to :world
  belongs_to :basecamp
  belongs_to :system

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
    if self.system_id.blank? && self.world
      self.system_id = self.world.system_id
    end
  end

  def update_world_surveys
    surveys = Survey.by_world_id(self.world_id).all
    if surveys.any?
      world_survey = WorldSurvey.by_world_id(self.world_id).first_or_initialize
      world_survey.assign_attributes({
        updater: self.commander,
        world_id: self.world_id
      })
      Material.all.map(&:name).each do |mat|
          world_survey.assign_attributes(mat => nil) 
      end
      surveys.each do |survey|
        Material.all.map(&:name).reduce(world_survey) do |acc, mat|
          if survey[mat] && survey[mat] > 0
            acc.assign_attributes(mat => true) 
          end
          acc
        end
      end
      world_survey.save
    else
      WorldSurvey.by_world_id(self.world_id).destroy_all
    end
  end
end

