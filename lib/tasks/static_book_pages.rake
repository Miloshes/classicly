namespace :static_book_pages do
  
  task :generate => :environment do
    Book.order('id ASC').each do |book|
      book.book_pages.order('page_number ASC').each do |page|
        av = ActionView::Base.new(Rails::Application::Configuration.new(Rails.root).view_path)
        av.class_eval do
          include ApplicationHelper
        end
        
        include ActionController::UrlWriter
        default_url_options[:host] = 'classicly.com'
        
        result = av.render_to_string(
            :template => "book_pages/show",
            :locals => {:page => page},
            :layout => nil#'layouts/static_book_pages'
          )
        
        puts result.inspect
        # "page_number"
        # "first_character"
        # "last_character"
        # "content"
        # "first_line_indent"        
      end
    end
  end
  
end