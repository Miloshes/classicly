namespace :staging_server do

  desc "Reads in unexported users and all the content they created, uploads result YAML file to S3"
  task :export_user_content => :environment do
    migrator = StagingToProductionMigrator.new
    migrator.export_and_upload_user_content
  end

  desc "Sets up the migrator for first time run"
  task :setup_for_first_run => :environment do
    migrator = StagingToProductionMigrator.new
    migrator.setup_for_first_run
  end

end