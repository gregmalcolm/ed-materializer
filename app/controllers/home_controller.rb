class HomeController < ApplicationController
  def index
    render text: "<h3>Elite Dangerous Materializer API</h3><a href='https://github.com/gregmalcolm/ed-materializer/wiki/Schema'>Schema V4</a>"
  end
end
