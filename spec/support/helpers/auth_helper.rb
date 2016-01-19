module AuthHelper
  def sign_in(user)
    json = post('api/v1/auth/sign_in.json',
                { email: user.email, password: user.password },
                {})
    { "uid" => "", "access_token" => "", "client" => "" }
  end

  def spawn_users
    { marlon: create(:user, name: "Marlon Blake", email: "marlon@example.com"),
      cruento: create(:user, name: "Cruento Mucrone", email: "cruento@example.com"),
      finwen: create(:user, name: "Finwen", email: "finwen@example.com"),
      edd: create(:user, :admin, name: "EDDiscovery", email: "edd@example.com") }
  end
end

