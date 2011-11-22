class LoginMailer < ActionMailer::Base

  def registration_notification_for_web(user)
    @user = user
    
    default_url_options[:host] = "www.classicly.com"
    default_url_options[:host] = "classicly-staging.heroku.com" if Rails.env.staging?
    
    mail(
        :to       => @user.email,
        :from     => "hello@classicly.com",
        :reply_to => "colin@spreadsong.com",
        :subject  => "Welcome to Classicly -- and Free Books/Free Audiobooks!",
        :date     => Time.now
      )
  end
  
  def registration_notification_for_ios(user)
    @user = user
    
    default_url_options[:host] = "www.classicly.com"
    default_url_options[:host] = "classicly-staging.heroku.com" if Rails.env.staging?
    
    mail(
        :to       => @user.email,
        :from     => "hello@classicly.com",
        :reply_to => "colin@spreadsong.com",
        :subject  => "Welcome to Classicly -- and Free Books/Free Audiobooks!",
        :date     => Time.now
      )
  end
end