require 'indextank'
require 'iconv'

namespace :indextank do

  def encode_utf(str)
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    ic.iconv(str + ' ')[0..-2]
  end

  def is_ascii?(str)
    str.each_byte {|c| return false if c>=128}
    true
  end

  task :index_books => :environment do
    index = IndexTankInitializer::IndexTankService.get_index('ClassiclyAutocomplete')

    Book.find_in_batches :batch_size => 200 do |books|
      documents = []
      books.each do|book|
        # You can use this if your database is corrupted. I had a clean one.
        # title = encode_utf(book.pretty_title)
        # author_name = encode_utf(book.author.name)
        
        title       = book.pretty_title
        author_name = book.author_name
        docid       = "b_#{book.id}"

        if is_ascii? docid # indextank does not index non ASCII ids.
          # we are going to save the cover url as a field to avoid more processing in read time:
          cover_url       = "http://spreadsong-book-covers.s3.amazonaws.com/book_id#{book.id}_size1.jpg"
          slug            = "/#{book.author_cached_slug}/#{book.cached_slug}" # save the slug as well.
          downloads_count = book.downloaded_count.nil? ? 0 : book.downloaded_count
          documents << {
            :docid => docid,
            :fields => {
              :text      => title,
              :author    => author_name,
              :type      => 'book',
              :cover_url => cover_url,
              :slug      => slug
            }, 
            :variables => { 0 => downloads_count }
          }
        end
      end

      response = index.batch_insert(documents)
      puts "sending to indextank: #{response}"
    end
  end

  task :index_audiobooks => :environment do
    index = IndexTankInitializer::IndexTankService.get_index('ClassiclyAutocomplete')

    Audiobook.find_in_batches :batch_size => 200 do |audiobooks|
      documents = []

      audiobooks.each do |audiobook|
        # title = encode_utf(audiobook.pretty_title)
        # author_name = encode_utf(audiobook.author.name)

        docid = "ab_#{audiobook.id}"

        if is_ascii? docid
          # we are going to save the cover url as a field to avoid more processing in read time:
          cover_url       = "http://spreadsong-audiobook-covers.s3.amazonaws.com/audiobook_id#{audiobook.id}_size1.jpg"
          slug            = "/#{audiobook.author_cached_slug}/#{audiobook.cached_slug}" # save the slug as well.
          downloads_count = audiobook.downloaded_count.nil? ? 0 : audiobook.downloaded_count

          #puts "abook content: #{text}"
          #puts "key: #{docid}"

          documents << {
            :docid => docid,
            :fields => {
              :text      => audiobook.pretty_title,
              :author    => audiobook.author_name,
              :type      => 'audiobook',
              :slug      => slug,
              :cover_url => cover_url
            },
            :variables => { 0 => downloads_count}
          }
        end
      end
      response = index.batch_insert(documents)
      puts "sending to indextank: #{response}"
    end
  end

  task :index_collections => :environment do
    index = IndexTankInitializer::IndexTankService.get_index('ClassiclyAutocomplete')
    collection_names = []

    Collection.find_in_batches :batch_size => 200 do |collections|
      documents = []

      collections.each do |collection|
        write = collection_names.include?(collection.name) ? false : true
        collection_names.push(collection.name) if write

        docid = "c_#{collection.id}"
        if (is_ascii? docid) && write
          # we are going to save the cover url as a field to avoid more processing in read time:
          slug = "/#{collection.cached_slug}"
          # puts "collection text: #{text}"
          # puts "key: #{docid}"
          documents << { :docid => docid, :fields => { :text => collection.name, :type => "collection", :slug => slug } }
        end
      end

      response = index.batch_insert(documents)
      puts "sending to indextank: #{response}"
    end
  end

  task :delete_collections => :environment do
    index = IndexTankInitializer::IndexTankService.get_index('ClassiclyAutocomplete')

    Collection.find_in_batches :batch_size => 200 do |collections|
      collections.each do|collection|
        docid = "c_#{collection.id}"
        index.document(docid).delete()
        puts "deleting collection : #{docid}"
      end
    end
  end

  task :delete_audiobooks => :environment do
    index = IndexTankInitializer::IndexTankService.get_index('ClassiclyAutocomplete')

    Audiobook.find_in_batches :batch_size => 200 do |audiobooks|
      audiobooks.each do|audiobook|
        docid = "ab_#{audiobook.id}"
        index.document(docid).delete()
      end
    end
  end
  
end
