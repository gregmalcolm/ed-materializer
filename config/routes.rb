Rails.application.routes.draw do
  scope :api, module: :api do
    scope :v1, module: :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'
      resources :world_surveys, except: [:new, :edit]
      get :change_logs, to: "change_logs#index"
    end
  end

  get "/401" => "errors#unauthorized"
  get "/404" => "errors#not_found"
  get "/500" => "errors#exception"

  root "home#index"
end
