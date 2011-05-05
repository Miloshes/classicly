class ReviewMailer < ActionMailer::Base

  def notification_on_flowdock(review)
    @review = review
    mail  :to => "main@spreadsong.flowdock.com",
          :from => "colin@spreadsong.com",
          :subject => "A new review has been posted",
          :date => Time.now
  end
end
