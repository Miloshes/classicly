Classicly::Application.routes.draw do
  match "/:id" => "seo#show", :as => 'seo', :via => :get
  match "/:author_id/:id" => "books#show", :as => :author_book, :via => :get
  match "/:author_id/:id/download" => "books#download", :as => 'download_book', :via => :post
  root :to => 'pages#main'
end
