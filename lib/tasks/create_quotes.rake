require 'fastercsv'

desc 'creates quote objects from a csv file with authors and their quotes'

namespace :quotes do
  task :create => :environment do
    Quote.delete_all
    file = 'public/quotes_csv.txt'
    FasterCSV.foreach(file, :col_sep =>'|', :row_sep =>:auto) do |row|
      collection = Collection.find_by_name_and_book_type(row[0], 'book')
      author = Author.find_by_name(row[0])
      quote = Quote.create(:collection_id => collection.try(:id), :author_id => author.try(:id), :content => row[1])
      puts "Creating quote #{quote.id}"
    end
  end
end