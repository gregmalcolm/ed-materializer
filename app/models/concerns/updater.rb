module Updater
  extend ActiveSupport::Concern
  
  included do
    before_validation :set_creator
    
    scope :by_updater, ->(updater) { where("UPPER(TRIM(updater))=?", updater.to_s.upcase.strip ) if updater }
  end
  
  def creator
    updaters.first if updaters
  end

  private 

  def set_creator
    self.updaters = [updater] if updater
  end
end
