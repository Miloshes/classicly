# Script to match books to audiobooks using their titles and author names. The migration runs on the iOS app database.
class BookAudiobookRelationMigration < ActiveRecord::Migration
  
  class Book < ActiveRecord::Base
    belongs_to :author
  end

  class Audiobook < ActiveRecord::Base
    belongs_to :author
  end
  
  def self.collect_matches
    books_that_need_author_matching = {
      :by_id => [593, 999, 1491, 3385, 3678, 3679, 3801, 5974, 6010, 9419, 10116, 12046, 12452, 12500, 12759, 13746, 13954, 14022, 14024, 17310, 17815, 18016, 18056, 18149, 19218, 19318, 20013, 20014, 20219, 20220, 20361, 20385, 20562, 20935, 21753, 22067],
      :by_title => ["Poems", "Sonnets"]
    }
    
    result = []
    
    Book.order(:id).each do |book|
      audiobooks = Audiobook.where(:title.matches => book.pretty_title).all()
      
      next if audiobooks.blank?
      
      needs_author_check = false
      
      # the titles already match for the book and audiobook, have to decide to check the authors too
      # NOTE: this is based on exceptions, because author match would decrease the result set significantly (as H.G. Wells != H. G. Wells)
      # so we only check when it's sure it'd be a mismatch
      if books_that_need_author_matching[:by_id].include?(book.id) || books_that_need_author_matching[:by_title] == book.title
        needs_author_check = true
      end
      
      audiobooks.each do |audiobook|
        if needs_author_check
          if (book.author && audiobook.author) && (book.author.id == audiobook.author.id)
            result << {:book_id => book.id, :audiobook_id => audiobook.id}
          end
        else
          result << {:book_id => book.id, :audiobook_id => audiobook.id}
        end
      end
    end
    
    # books that we know that are a match but wouldn't be found by the script
    # Aesop's fables
    [287, 288, 289, 290].each do |book_id|
      (1..12).to_a.each do |audiobook_id|
        result << {:book_id => book_id, :audiobook_id => audiobook_id}
      end
    end
    
    return result
  end
  
  def self.up
    data_to_save = BookAudiobookRelationMigration.collect_matches
    
    # == iOS SQLite DB for books
    ActiveRecord::Base.establish_connection :ios_book_db
    
    add_column :books, :related_audiobooks, :text
    Book.reset_column_information
    
    data_to_save.each do |record|
      book = Book.find(record[:book_id])
      
      if book.related_audiobooks.blank?
        book.update_attributes(:related_audiobooks => record[:audiobook_id])
      else
        book.update_attributes(:related_audiobooks => book.related_audiobooks + ',' + record[:audiobook_id].to_s)
      end
    end
    
    # == iOS SQLite DB for books
    ActiveRecord::Base.establish_connection :ios_audiobook_db
    
    add_column :audiobooks, :related_books, :text
    Audiobook.reset_column_information
    
    data_to_save.each do |record|
      audiobook = Audiobook.find(record[:audiobook_id])
      
      if audiobook.related_books.blank?
        audiobook.update_attributes(:related_books => record[:book_id])
      else
        audiobook.update_attributes(:related_books => audiobook.related_books + ',' + record[:book_id].to_s)
      end
    end
  end
end

namespace :book_audiobook_matcher do
  
  task :match_and_migrate => :environment do
    BookAudiobookRelationMigration.up
  end
  
end