Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  scope :api, module: :api do
    scope :v2, module: :v2 do
      resources :systems, except: [:new, :edit] do
        collection do
          get :download
          get :md5
        end
        resources :stars, except: [:new, :edit] do
          collection do
            get :download
            get :md5
          end
        end
        resources :worlds, except: [:new, :edit] do
          collection do
            get :download
            get :md5
          end
        end
      end
      resources :stars, except: [:new, :edit] do
        collection do
          get :download
          get :md5
        end
      end
      resources :worlds, except: [:new, :edit] do
        collection do
          get :download
          get :md5
        end
        resources :basecamps, except: [:new, :edit] do
          collection do
            get :download
            get :md5
          end
        end
        resources :world_surveys, except: [:new, :edit] do
          collection do
            get :download
            get :md5
          end
        end
      end
      resources :basecamps, except: [:new, :edit] do
        collection do
          get :download
          get :md5
        end
        resources :site_surveys, except: [:new, :edit] do
          collection do
            get :download
            get :md5
          end
        end
      end
      resources :site_surveys, except: [:new, :edit] do
        collection do
          get :download
          get :md5
        end
      end
      resources :world_surveys, except: [:new, :edit] do
        collection do
          get :download
          get :md5
        end
      end
      get :change_logs, to: "change_logs#index"
    end
  end

  get "/401" => "errors#unauthorized"
  get "/404" => "errors#not_found"
  get "/500" => "errors#exception"

  root "home#index"
end
