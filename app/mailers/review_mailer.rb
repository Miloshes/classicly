class ReviewMailer < ActionMailer::Base
  def notification_on_flowdock(review)
    recipients "spreadsong <main@spreadsong.flowdock.com>"
    from       "Classicly.com"
    subject    "A new review has been posted"
    sent_on    Time.now
    body       :review => review
  end
end
