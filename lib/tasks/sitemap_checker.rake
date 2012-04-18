require 'net/http'
require 'nokogiri'


namespace :sitemap do
  
  desc 'Test generated sitemap'
  task :test => :environment do
    error_count = 0 
    
    Dir[RAILS_ROOT + '/public/sitemap?.xml.gz'].sort.each do |sitemap|
      doc = Zlib::GzipReader.open(sitemap) {|file| Nokogiri::XML(file.read) }
      doc.remove_namespaces! 
      doc.search('//url/loc').each do |location|
        url = location.content 
        url.gsub! 'www.classicly.com', 'localhost:3000'
        response = Net::HTTP.get_response URI(url)
        unless response.code != 200
          error_counter += 1
          File.open(RAILS_ROOT + '/../sitemap.log', 'a') do |log|
            str = "#{error_counter}. [#{response.class.name} #{response.code}] #{url}"
            log.puts str
            puts str
          end
        end
      end
    end
  end

end
