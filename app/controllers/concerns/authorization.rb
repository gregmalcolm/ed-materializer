module Authorization
  private

  def authorize_user!
    unless current_user &&
      permitted_application_change? ||
      permitted_user_change?
      render json: {errors: ["Authorized users only."]}, status: 401
      return false
    end
  end

  def permitted_application_change?
    current_user.try(:role) == "application"
  end
  
  def permitted_user_change?
    current_user.try(:role) == "user"
  end
end
