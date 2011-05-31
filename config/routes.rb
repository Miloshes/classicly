Classicly::Application.routes.draw do

  namespace 'admin' do
    root :to => "base#home"
    match 'sign_in' => 'admin_user_sessions#new', :as => 'sign_in'
    match 'logout' => 'admin_user_sessions#destroy', :as => 'logout'
    resource :admin_user_session
    resources :blog_posts
    resources :reviews, :only => [:index, :destroy]
  end
  
  # put here all the matches , except for the more general ones.
  match 'audiobook-collections' => 'pages#audio_collections'
  match 'audiobook-authors' => 'pages#audiobook_authors' 
  match 'collections' => 'pages#collections'
  match 'authors' => 'pages#authors'
  match 'json_books' => 'books#json_books'
  match 'json_audiobooks' => 'audiobooks#json_audiobooks'
  match 'collection_json_books' => 'collections#collection_json_books'

  # for delivering audiobook file
  match '/download_audiobook/:id' => 'audiobooks#serve_audiofile', :as => 'serve_audiofile', :via => :ge
  match 'random_json_audiobooks/:total_audiobooks' => 'audiobooks#random_json'
  match 'random_json_books/:total_books' => 'pages#random_json_books'
  match 'related_audiobooks/:id/:total_related' => 'audiobooks#related_audiobooks_in_json'
  match 'related_books/:id/:total_related' => 'books#related_books_JSON'
  match 'abingo' => "abingo_dashboard#index", :via => :get
  match 'abingo/end_experiment/:id' => "abingo_dashboard#end_experiment", :via => :post

  # TODO: remove, this is only here for testing
  match '/reader/:id/:page_number' => "book_pages#show", :via => :get
  # NOTE: this is for the first version of the review API, will be deprecated soon
  match "incoming_data" => "incoming_datas#create", :method => :post
  
  
  # the reader engine API
  match '/reader_engine_api' => "reader_engine_api#create", :via => :post
  match '/reader_engine_api/query' => "reader_engine_api#query", :via => :post  

  match '/facebook/like' => 'facebook_events#like', :via => :get

  resources :audiobooks, :only => :index do
    get :ajax_paginate, :on => :collection
  end

  get "bingo_experiments/create"

  match 'blog' => 'blog#index', :as => :blog
  match 'post/:id' => 'blog#show', :as => :post
  
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
  match 'search/autocomplete' => 'search#autocomplete'
  
  # current version of the web API
  match "/web_api" => "web_api#create", :via => :post
  match '/web_api/query' => "web_api#query", :via => :post

  match '/render_book_for_the_reader/:book_id' => "book_pages#render_book", :via => :get
  
  match "/:id" => "seo#show", :as => 'seo', :via => :get

  match "/:author_id/:id" => "seo#show_book", :as => :author_book, :via => :get

  match '/:author_id/:id/download-mp3' => "audiobooks#download", :as => 'download_audiobook', :via => :get
  
  # for invoking the download page and start the download
  match "/:author_id/:id/download/:download_format" => "books#download", :as => 'download_book', :via => :get

  # for invoking the download page from outside classicly.com
  match "/:author_id/:id/download/:download_format" => "books#download", :as => 'book_download_page', :via => :get
  
  # for delivering the book file (automatic file downloading)
  match "/books/:id/download_in_format/:download_format" => "books#serve_downloadable_file",
        :as => 'serve_downloadable_file', :via => :get
        
  # for invoking the book reader
  match '/:id/page/:page_number' => "book_pages#show",
  :as => 'read_online', :via => :get

  root :to => 'pages#main'
end
