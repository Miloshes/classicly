namespace :static_book_pages do
  
  # sets the force_rerender flag to true for all book pages, should be used after the parameters for the reader change
  task :force_rerender => :environment do
    BookPage.where(:force_rerender => false).update_all(:force_rerender => true)
  end
  
end