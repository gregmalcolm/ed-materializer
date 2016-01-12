Rails.application.routes.draw do
  scope :api, module: :api do
    scope :v1, module: :v1 do
      resources :world_surveys, except: [:new, :edit]
      get :change_logs, to: "change_logs#index"
    end
  end

  get "/404" => "errors#not_found"
  get "/500" => "errors#exception"

  root "home#index"
end
