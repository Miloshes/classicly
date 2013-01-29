desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  
  if Time.now.hour == 10
    Book.find_each do |book|
      book.set_average_rating
    end
    
    Audiobook.find_each do |audiobook|
      audiobook.set_average_rating
    end
  end
  
  if Time.now.hour == 12
    Library.clean_up_not_claimed_libraries
  end

  if Time.now.hour == 6
    migrator = StagingToProductionMigrator.new
    migrator.export_and_upload_user_content
  end
  
  if Time.now.hour == 2 # run once a day
    OnlineReader.update_cache
  end

  if Time.now.hour == 1 # run once a day
    Rake::Task['mailchimp:sync'].invoke
  end
  
end
