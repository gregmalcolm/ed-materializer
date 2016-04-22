class UsersShouldBeUserRoleAtFirst < ActiveRecord::Migration
  def up
    User.where(role: nil).update_all(role: "user")
    change_column :users, :role, :string, default: "user"
  end

  def down
    change_column :users, :role, :string
  end
end
