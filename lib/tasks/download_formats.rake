include AWS::S3

# This was a one-off script to update the download format database that we have. For each book it checks what format
# it's available for download.
# We can re-run it any time the book files on S3 changes.

class DownloadFormatHandler
  
  def self.check_availability
    AWS::S3::Base.establish_connection!(
        :access_key_id     => APP_CONFIG['amazon']['access_key'],
        :secret_access_key => APP_CONFIG['amazon']['secret_key']
      )
  
    formats_to_check_for = %w(azw pdb pdf prc rtf txt.zip)
    
    start_id = DownloadFormat.last.book.id
  
    Book.where('id >= ?', start_id).order('id ASC').each do |book|

      formats_to_check_for.each do |format|      
        object_key = "#{book.id}.#{format}"
        # 'txt.zip' is the base format that we'll be using to re-generate the books
        legacy_flag = format == 'txt.zip' ? false : true
      
        download_format = book.download_formats.where(:format => format, :legacy => legacy_flag).first()
        if download_format.blank?
          download_format = book.download_formats.create(:format => format, :legacy => legacy_flag)
        end
      
        if S3Object.exists?(object_key, APP_CONFIG['buckets']['books'])
          download_format.update_attributes(:download_status => 'downloaded')
        end
      end

    end
  end
  
end


namespace :download_formats do
  
  desc "Checks availability for the vaious download formats based on file existance in the S3 bucket.\n" +
       "It uses delayed_job so make sure to have a worker available."
  task :check_availability => :environment do
    DownloadFormatHandler.delay.check_availability
  end
  
end