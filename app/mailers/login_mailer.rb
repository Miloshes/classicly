class LoginMailer < ActionMailer::Base
  def registration_notification(user)
    @user = user
    mail  :to => @user.email,
          :from => "hello@classicly.com",
          :reply_to => "colin@spreadsong.com",
          :subject => "Welcome to Classicly -- and Free Books/Free Audiobooks!",
          :date => Time.now
  end
end