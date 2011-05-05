ActionMailer::Base.smtp_settings = {
  :address  => "smtp.sendgrid.net",
  :port  => 587,
  :user_name  => 'colin@spreadsong.com',
  :password  => 'Song2Sb891',
  :domain => 'classicly.com',
  :authentication  => 'plain',
  :enable_starttls_auto => true
}
