module AuthHelper
  def sign_in(user)
    request.headers["Accept"] = "application/vnd.api+json"
    request.headers["Content-Type"] = "application/vnd.api+json"
    token = user.create_new_auth_token
    user.create_new_auth_token.each_pair do |k,v| 
      request.headers[k]=v
    end
    token
  end

  def spawn_users
    { 
      marlon: create(:user, name: "Marlon Blake", email: "marlon@example.com"),
      cruento: create(:user, name: "Cruento Mucrone", email: "cruento@example.com"),
      finwen: create(:user, name: "Finwen", email: "finwen@example.com"),
      edd: create(:user, :application, name: "EDDiscovery", email: "edd@example.com"),
      banned: create(:user, :banned, name: "Blackbeard", email: "yarr@example.com"),
      admin: create(:user, :admin, name: "Dangermouse", email: "danger@example.com")
    }
  end
end

