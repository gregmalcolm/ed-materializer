module AuthHelper
  #def sign_in(user)
  #  user.create_new_auth_token
  #end

  def spawn_users
    { 
      marlon: create(:user, name: "Marlon Blake", email: "marlon@example.com"),
      cruento: create(:user, name: "Cruento Mucrone", email: "cruento@example.com"),
      finwen: create(:user, name: "Finwen", email: "finwen@example.com"),
      edd: create(:user, :application, name: "EDDiscovery", email: "edd@example.com"),
      banned: create(:user, :banned, name: "Blackbeard", email: "yarr@example.com")
    }
  end
end

