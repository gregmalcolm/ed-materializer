module Authorization
  private

  def authorize_application!
    unless current_user && current_user.role == "application"
      render json: {errors: ["Authorized users only."]}, status: 401
      return false
    end
  end
end
