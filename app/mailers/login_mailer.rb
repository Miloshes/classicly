class LoginMailer < ActionMailer::Base

  def registration_notification_for_web(user)
    set_url_options

    @user = user

    mail(
        :to       => @user.email,
        :from     => "hello@classicly.com",
        :reply_to => "colin@spreadsong.com",
        :subject  => "Welcome to Classicly -- and Free Books/Free Audiobooks!",
        :date     => Time.now
      )
  end
  
  def registration_notification_for_ios(user)
    set_url_options

    @user = user
    
    mail(
        :to       => @user.email,
        :from     => "hello@classicly.com",
        :reply_to => "colin@spreadsong.com",
        :subject  => "Welcome to Classicly -- and Free Books/Free Audiobooks!",
        :date     => Time.now
      )
  end

  def password_reset(user)
    set_url_options
    
    @user = user
    
    mail(
        :to       => @user.email,
        :from     => "hello@classicly.com",
        :reply_to => "colin@spreadsong.com",
        :subject  => "Classicly -- trying to reset your password?",
        :date     => Time.now
      )
    
  end

  private

  def set_url_options
    case Rails.env
    when "production"
      default_url_options[:host] = "www.classicly.com"
    when "staging"
      default_url_options[:host] = "classicly-staging.heroku.com"
    when "development"
      default_url_options[:host] = "localhost:3000"
    when "test"
      default_url_options[:host] = "localhost:3000"
    end
  end

end