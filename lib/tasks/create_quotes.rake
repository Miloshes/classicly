desc 'creates quote objects from a file with authors and their quotes'

namespace :quotes do
  task :create => :environment do
    Quote.delete_all
    file    = 'public/New_quote_list_2.rtf'
    parser  = QuotesFileParser.new file
    parser.parse_quotes_file_to_array
    quotes_array = parser.final_quotes
    
    quotes_array.each do |row|
      collection = Collection.find_by_name_and_book_type(row[0], 'book')
      author = Author.find_by_name(row[0])
      quote = Quote.create(:collection_id => collection.try(:id), :author_id => author.try(:id), :content => row[1])
      puts "Creating quote for author: #{row[0]} => Quote: #{row[1]}"
    end
  end
end
