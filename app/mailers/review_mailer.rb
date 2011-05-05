class ReviewMailer < ActionMailer::Base

  def notification_on_flowdock(review)
    @review = review
    mail  :to => "spreadsong <main@spreadsong.flowdock.com>",
          :from => "Classicly.com",
          :subject => "A new review has been posted",
          :sent_on => Time.now
  end
end
