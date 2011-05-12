require 'indextank'
require 'iconv'

namespace :indextank do
  $ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
  task :index_books => :environment do
    index = IndexTankInitializer::IndexTankService.get_index('classicly_staging')
    Book.find_in_batches :batch_size => 200 do|books|
      documents = []
      books.each do|book|
        title = encode_utf(book.pretty_title)
        author_name = encode_utf(book.author.name)
        docid = "b_#{book.id}"
        if is_ascii? docid
          text = "#{title} , #{author_name} "
          #add collection names to the text to find collection's books
          book.collections.each do |collection|
            text << ", #{collection.name}"
          end
          puts "book content: #{text}"
          puts "key: #{docid}"
          documents << { :docid => docid, :fields => { :text => text } }
        end
      end
      response = index.batch_insert(documents)
      puts "sending to indextank: #{response}"
    end
  end
  
  task :index_audiobooks => :environment do
    index = IndexTankInitializer::IndexTankService.get_index('classicly_staging')
    Audiobook.find_in_batches :batch_size => 200 do|audiobooks|
      documents = []
      audiobooks.each do|audiobook|
        title = encode_utf(audiobook.pretty_title)
        author_name = encode_utf(audiobook.author.name)
        docid = "ab_#{audiobook.id}"
        if is_ascii? docid
          text = "#{title} , #{author_name} "
          #add collection names to the text to find collection's books
          audiobook.collections.each do |collection|
            text << ", #{encode_utf(collection.name)}"
          end
          puts "abook content: #{text}"
          puts "key: #{docid}"
          documents << { :docid => docid, :fields => { :text => text } }
        end
      end
      response = index.batch_insert(documents)
      puts "sending to indextank: #{response}"
    end
  end
  
  task :index_collections => :environment do
    index = IndexTankInitializer::IndexTankService.get_index('classicly_staging')
    Collection.find_in_batches :batch_size => 200 do|collections|
      documents = []
      collections.each do|collection|
        title = encode_utf(collection.name)
        docid = "c_#{collection.id}"
        if is_ascii? docid
          text = title
          puts "collection text: #{text}"
          puts "key: #{docid}"
          documents << { :docid => docid, :fields => { :text => text } }
        end
      end
      response = index.batch_insert(documents)
      puts "sending to indextank: #{response}"
    end
  end

  def encode_utf(str)
    $ic.iconv(str + ' ')[0..-2]
  end
  

  def is_ascii?(str)
    str.each_byte {|c| return false if c>=128}
    true
  end
  
end