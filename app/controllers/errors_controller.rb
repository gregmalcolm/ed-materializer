class ErrorsController < ActionController::Base
  def not_found
    if env["REQUEST_PATH"] =~ /^\/api/
      render :json => {:error => "not-found"}.to_json, :status => 404
    else
      render :text => "404 Not found", :status => 404
    end
  end

  def exception
    if env["REQUEST_PATH"] =~ /^\/api/
      render :json => {:error => "internal-server-error"}.to_json, :status => 500
    else
      render :text => "500 Internal Server Error", :status => 500
    end
  end
end
