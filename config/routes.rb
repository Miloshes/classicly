Classicly::Application.routes.draw do

  namespace 'admin' do
    resources :reviews, :only => [:index, :destroy]
  end

  match 'abingo' => "abingo_dashboard#index", :via => :get
  match 'abingo/end_experiment/:id' => "abingo_dashboard#end_experiment", :via => :post

  resources :audiobooks, :only => :index do
    get :ajax_paginate, :on => :collection
  end

  get "bingo_experiments/create"

  resources :books, :only => :index do
    get :ajax_paginate, :on => :collection
    get :show_review_form, :on => :member
    resources :reviews
  end

  resources :collections, :only => :show do
    resources :reviews
  end

  # NOTE: this is for the first version of the review API, will be deprecated soon
  match "incoming_data" => "incoming_datas#create", :method => :post

  resources :logins, :only => [:create] do
    delete :destroy, :on => :collection
  end

  match 'search' => 'search#show'

  # current version of the web API
  match "/web_api" => "web_api#create", :via => :post
  match '/web_api/query' => "web_api#query", :via => :post

  match "/:id" => "seo#show", :as => 'seo', :via => :get

  match "/:author_id/:id" => "seo#show_book", :as => :author_book, :via => :get

  # for invoking the download page and start the download
  match "/:author_id/:id/download" => "books#download", :as => 'download_book', :via => :post

  
  # for invoking the download page from outside classicly.com
  match "/:author_id/:id/download/:download_format" => "books#download", :as => 'book_download_page', :via => :get

  # for delivering audiobook file
  match '/download_audiobook/:id/:chapter_id' => 'audiobooks#serve_audiofile', :as => 'serve_audiofile', :via => :get
  
  # for delivering the book file (automatic file downloading)
  match "/books/:id/download_in_format/:download_format" => "books#serve_downloadable_file",
        :as => 'serve_downloadable_file', :via => :get
  
  root :to => 'pages#main'
end
