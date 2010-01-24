class UserNotifier < ActionMailer::Base

  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://fypurl.com/activate_account/#{user.activation_code}"
  end

  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://fypurl.com/#{user.login}"
  end

  def new_password(user, password)
    setup_email(user)
    @subject += 'New password for you'
    @body[:url] = "http://fypurl.com"
    @body[:password] = password
  end


  protected

  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "The happily fypped FYPpurl team <postmaster@fypurl.com>"
    @subject     = "[FYPURL] "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
