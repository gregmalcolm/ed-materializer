class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?

  def model
    controller_name.classify.constantize rescue nil
  end
  
  def page
    params[:page] || 1
  end

  def per_page
    params[:per_page] || 20
  end
  
  def ordering
    sort_column ? "#{sort_column} #{sort_direction}" : "updated_at"
  end
  
  def sort_column
    @sort_column ||= (
      params[:sort] if model.column_names.include?(params[:sort].to_s)
    )
  end
  
  def sort_direction
    (params[:direction] == "desc") ? "desc" : "asc"
  end
  
  
  private

  def configure_permitted_parameters
    sign_up_permits = [ :name, :email, :password, :password_confirmation]
    
    # The right way
    devise_parameter_sanitizer.for(:sign_up) do |user_params|
      user_params.permit(sign_up_permits)
    end

    # Workarounds
    devise_parameter_sanitizer.instance_values['permitted'][:sign_up] = sign_up_permits
    
  end
end
