# config/initializers/index_tank.rb
# initializes index tank service
require 'indextank'

module IndexTankInitializer
  # load YML configuration
  CONFIG = YAML.load_file(Rails.root.join("config/app_config.yml"))
  # assign properties
  INDEX_TANK_API_URL = CONFIG['index_tank']['private_api_url']
  INDEX_TANK_PUBLIC_API_URL = CONFIG['index_tank']['public_api_url']

  class IndexTankService
    def self.client
      IndexTank::Client.new INDEX_TANK_API_URL
    end

    def self.get_index(name)
      index = self.client.indexes name
      index.add unless index.exists?
      sleep 0.5 while not index.running?
      index
    end
  end
end
