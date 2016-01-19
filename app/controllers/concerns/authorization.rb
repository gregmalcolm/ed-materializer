module Authorization
  private

  def authorize_admin!
    unless current_user && current_user.role == "admin"
      render json: {errors: ["Authorized users only."]}, status: 401
      return false
    end
  end
end
