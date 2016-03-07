class AdminsAreNowApplications < ActiveRecord::Migration
  def change
    users = User.where("role='admin' AND created_at < ?", Date.parse("2016-3-3"))
    users.update_all(role: 'application')
  end
end
