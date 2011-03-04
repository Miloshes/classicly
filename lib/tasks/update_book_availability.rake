desc 'Update format availabilty for books - Books that are not in azw, pdf, or rtf format will be set to false'
task :update_book_availability => :environment do
  Book.available_in_formats(['awz', 'pdf', 'rtf'])
end
