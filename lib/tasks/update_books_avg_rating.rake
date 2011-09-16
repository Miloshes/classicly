# CLEANUP: obsolete, the cron job does that already

desc 'Update average rating for books '
task :update_books_avg_rating => :environment do
  Book.find_each do |book|
    puts 'Updating rating for book: ' + book.title
    book.set_average_rating
  end
end
