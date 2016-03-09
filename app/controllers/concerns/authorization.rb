module Authorization
  private

  def authorize_user!
    unless admin? || application? || user?
      render json: {errors: ["Authorized users only."]}, status: 401
      return false
    end
  end

  def authorize_change!(owner, app_user)
    unless admin?
      unless changer(app_user) == owner
        render json: {errors: ["Unauthorized change."]}, status: 401
        return false
      end
    end
  end

  def application?
    current_user.try(:role) == "application"
  end
  
  def user?
    current_user.try(:role) == "user"
  end
  
  def admin?
    current_user.try(:role) == "admin"
  end

  def changer(app_user)
    application? ? app_user : current_user.try(:name)
  end
end
