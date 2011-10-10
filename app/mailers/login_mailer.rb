class LoginMailer < ActionMailer::Base
  def registration_notification(user)
    @user = user
    mail  :to => user.email,
          :from => "colin@spreadsong.com",
          :subject => "Welcome to Classicly!",
          :date => Time.now
  end
end