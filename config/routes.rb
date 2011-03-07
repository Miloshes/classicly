Classicly::Application.routes.draw do
  match "/books/:id/download" => "books#download", :as => 'download_book', :via => :post
  match "/:id" => "seo#show", :as => 'seo', :via => :get
  root :to => 'pages#main'
end
