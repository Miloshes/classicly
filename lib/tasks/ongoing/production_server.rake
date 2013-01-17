namespace :production_server do

  desc "Reads user content exported from the staging server and imports it into the database"
  task :import_user_content => :environment do
    migrator = StagingToProductionMigrator.new
    migrator.import_user_content
  end
  
end