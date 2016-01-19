class ErrorsController < ActionController::Base
  def not_found
    if env["REQUEST_PATH"] =~ /^\/api/
      render json: { error: "Not found." }, status: 404
    else
      render :text => "404 Not found", :status => 404
    end
  end

  def exception
    if env["REQUEST_PATH"] =~ /^\/api/
      render json: {errors: ["Internal server error."]}, status: 500
    else
      render text: "500 Internal Server Error", status: 500
    end
  end

  def unauthorized
    if env["REQUEST_PATH"] =~ /^\/api/
      render json: {errors: ["Authorized users only."]}, status: 401
    else
      render text: "401 Unauthorized", status: 401
    end
  end
end
