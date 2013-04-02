project_type = :rails
http_path = "/"

# NOTE
# Compass returns :development for the Heroku staging environment, so we check Rails.root wich is 
# "/app" on Heroku and the local path on the localhost

if Compass::AppIntegration::Rails.env == :development && !Compass::AppIntegration::Rails.root.to_s.start_with?("/app")
  css_dir = "public/stylesheets/compiled"
else
  css_dir = "tmp/stylesheets"
end

sass_dir = "app/stylesheets"
environment = Compass::AppIntegration::Rails.env