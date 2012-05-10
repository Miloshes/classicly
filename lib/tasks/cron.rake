desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  
  if Time.now.hour % 4 == 0 # run every 2 hours
    Book.find_each do |book|
      book.set_average_rating
    end
    
    Audiobook.find_each do |audiobook|
      audiobook.set_average_rating
    end
  end
  
  if Time.now.hour % 12 == 0 # run every 12 hours
    Library.clean_up_not_claimed_libraries
  end
  
  if Time.now.hour == 0 # run once a day
    OnlineReader.update_cache
  end

  if Time.now.hour == 2 and Time.now.day % 7 == 0
    Rake::Task['mailchimp:sync'].invoke
  end
  
end
