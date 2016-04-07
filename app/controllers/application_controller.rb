class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Authorization
  def page
    params[:page] || 1
  end

  def per_page
    params[:per_page] || 20
  end
end
