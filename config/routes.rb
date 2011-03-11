Classicly::Application.routes.draw do

  resources :books, :only => :index do
    get :ajax_paginate, :on => :collection
  end

  resource :search, :only => :show, :controller => :search do
  end

  match "/:id" => "seo#show", :as => 'seo', :via => :get
  match "/:author_id/:id" => "books#show", :as => :author_book, :via => :get
  
  # for invoking the download page and start the download
  match "/:author_id/:id/download" => "books#download", :as => 'download_book', :via => :post
  
  # for invoking the download page from outside classicly.com
  match "/:author_id/:id/download/:download_format" => "books#download", :as => 'book_download_page', :via => :get
  
  # for delivering the book file (automatic file downloading)
  match "/books/:id/download_in_format/:download_format" => "books#serve_downloadable_file",
        :as => 'serve_downloadable_file', :via => :get
  
  root :to => 'pages#main'
end
