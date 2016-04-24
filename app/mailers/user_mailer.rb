class UserMailer < ApplicationMailer
 default :from => "noreply@edmaterializer.com"

  def test_email
    Rails.logger.debug 'test_email'
    mail(:to => 'gregmalcolm@gmail.com', :subject => "testing rails")
  end
end
