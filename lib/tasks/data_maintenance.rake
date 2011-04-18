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
end