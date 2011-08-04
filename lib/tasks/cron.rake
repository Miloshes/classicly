desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  
  if Time.now.hour % 2 == 0 # run every 2 hours
    Book.find_each do |book|
      book.set_average_rating
    end
    
    Audiobook.find_each do |audiobook|
      audiobook.set_average_rating
    end
  end
  
  if Time.now.hours % 12 == 0 # run every 12 hours
    Library.clean_up_not_claimed_libraries
  end
  
end