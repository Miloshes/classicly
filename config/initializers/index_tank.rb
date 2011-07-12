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
      client = self.client
      write_index = client.indexes[name].nil?
      index = client.indexes name
      index.add if write_index

      while not index.running?
          sleep 0.5
      end
      index
    end
  end
end
