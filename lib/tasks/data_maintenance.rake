require 'iconv'
namespace :data_maintenance do
  task :encode_audio_book_chapter_titles => :environment do
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    AudiobookChapter.find_each do |chapter|
      valid_string = ic.iconv(chapter.title + ' ')[0..-2]
      chapter.update_attribute :title, valid_string
      puts "encoding chapter: (#{chapter.id})#{chapter.title}"
    end
  end
  
  task :encode_audiobook_descriptions => :environment do
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    Audiobook.find_each do |abook|
      unless abook.description.nil?
        valid_string = ic.iconv(abook.description + ' ')[0..-2]
        abook.update_attribute :description, valid_string
        puts "encoding audiobook: (#{abook.id})"
      end
    end
  end
end
