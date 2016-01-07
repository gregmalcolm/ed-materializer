Rails.application.routes.draw do
  scope "/api" do
    scope "/v1" do
      resources :world_surveys, except: [:new, :edit]
    end
  end

  root "home#index"
end
