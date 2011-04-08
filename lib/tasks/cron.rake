desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  
  if Time.now.hour % 1 == 0 # run every hour
    Book.find_each do |book|
      book.set_average_rating
    end
  end
  
end