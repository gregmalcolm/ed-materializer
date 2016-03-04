class AdminsAreNowApplications < ActiveRecord::Migration
  def change
    User.where("role='admin' AND created_at < ?", Date.parse("2016-3-3"))
  end
end
