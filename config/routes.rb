Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  scope :api, module: :api do
    scope :v1, module: :v1 do
      resources :world_surveys, except: [:new, :edit]
      resources :star_surveys, except: [:new, :edit]
      get :change_logs, to: "change_logs#index"
    end
    scope :v2, module: :v2 do
      resources :stars, except: [:new, :edit]
      resources :worlds, except: [:new, :edit] do
        resources :basecamps, except: [:new, :edit]
      end
      resources :world_surveys, except: [:new, :edit]
      get :basecamps, to: "basecamps#index"
      get :change_logs, to: "change_logs#index"
    end
  end

  #mount_devise_token_auth_for 'User', at: '/api/v1/auth'

  get "/401" => "errors#unauthorized"
  get "/404" => "errors#not_found"
  get "/500" => "errors#exception"

  root "home#index"
end
