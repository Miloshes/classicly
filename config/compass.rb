# project_type = :rails
# http_path = "/"
# css_dir = "public/stylesheets/compiled"
# sass_dir = "app/stylesheets"


project_type = :rails
http_path = "/"

if Compass::AppIntegration::Rails.env == "development"
  css_dir = "public/stylesheets/compiled"
else
  css_dir = "tmp/stylesheets"
end

sass_dir = "app/stylesheets"
environment = Compass::AppIntegration::Rails.env

# Old version
# project_type = :rails
# project_path = Compass::AppIntegration::Rails.root
# http_path = "/"
# css_dir = "public/stylesheets/compiled"
# sass_dir = "app/stylesheets"
# environment = Compass::AppIntegration::Rails.env
