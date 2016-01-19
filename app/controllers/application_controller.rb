class ApplicationController < ActionController::API
  #protect_from_forgery with: :null_session
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Authorization
  def page
    params[:page] || 1
  end

  def per_page
    params[:per_page] || 500
  end
end
