class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Authorization
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

end
