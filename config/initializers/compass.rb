require 'fileutils'
FileUtils.mkdir_p(Rails.root.join("tmp", "stylesheets"))

Rails.configuration.middleware.insert_before('Rack::Sendfile', 'Rack::Static',
    :urls => ['/stylesheets'],
    :root => "#{Rails.root}/tmp")

require 'compass'
Sass.load_paths << Compass::Frameworks['compass'].stylesheets_directory
Sass.load_paths << Compass::Frameworks['blueprint'].stylesheets_directory