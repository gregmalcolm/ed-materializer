Rails.application.routes.draw do
  scope :api, module: :api do
    scope :v1, module: :v1 do
      resources :world_surveys, except: [:new, :edit]
    end
  end

  root "home#index"
end
