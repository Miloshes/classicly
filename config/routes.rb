Classicly::Application.routes.draw do

  namespace 'admin' do
    root :to => "base#home"
    match 'abingo' => "abingo_dashboard#index", :via => :get
    match 'abingo/end_experiment/:id' => "abingo_dashboard#end_experiment", :via => :post
    match 'admin_seo' => 'admin_seo#main'
    match 'admin_seo/:type' => 'admin_seo#admin_infoable', :as => 'admin_infoable'
    match 'admin_seo/:type/:id' => 'admin_seo#edit_seo', :as => 'edit_seo'
    match 'admin_seo/:type/:id/update_seo_info' => 'admin_seo#update_seo_info', :as => 'update_seo_info'
    match 'blog_posts/associate_book' => 'blog_posts#associate_book'

    # == Admin user related
    match 'logout' => 'admin_user_sessions#destroy', :as => 'logout'
    match 'sign_in' => 'admin_user_sessions#new', :as => 'sign_in'
    resource :admin_user_session

    resources :blog_posts do
      member do
        get 'change_state'
        get 'preview'
      end
    end

    resources :reviews, :only => [:index, :destroy] do
      member do
        put 'toggle_featured'
      end
    end
    resources :seo_defaults
  end

  resources :bookmarks, :only => [:create, :destroy]

  # == User related
  resource :logins, :only => [:create]
  resources :password_resets
  match 'reset_password' => "password_resets#new"
  match "reset_password/token/:id" => "password_resets#edit", :as => :reset_password
  match '/unsubscribe' => 'logins#unsubscribe', :as => :unsubscribe
  post 'mailchimp_callback' => 'logins#mailchimp_callback'

  # == Library
  match 'library' => 'libraries#show', :as => :library
  match 'library/handle_facebook_login' => 'libraries#handle_facebook_login', :as => :library_handle_facebook_login
  match 'books/:book_id/download_and_add_to_library/:download_format' => 'books#download_and_add_to_library', :as => :download_and_add_to_library

  # == Static-y Pages
  match "about" => "pages#about"
  match "terms-ipad" => "pages#terms_of_service_for_ipad"
  match 'audiobook-collections' => 'pages#audio_collections'
  match 'audiobook-authors' => 'pages#audiobook_authors'
  match 'authors/(:page)' => 'pages#authors', :as => :authors
  match '/apps' => 'pages#apps'
  match 'blog' => 'blog#index', :as => :blog

  match 'collections/autocomplete' => 'collections#autocomplete'
  match 'collections/(:page)' => 'pages#collections', :as => :collections
  match '/dmca' => 'pages#dmca'
  match '/iphone' => 'pages#iphone'
  match '/ipad' => 'pages#ipad'
  match 'sitemap.xml' => redirect('/sitemap_index.xml.gz')

  # for delivering audiobook file
  match '/download_audiobook/:id' => 'audiobooks#serve_audiofile', :as => 'serve_audiofile', :via => :get

  # TODO: remove, this is only here for testing
  match '/reader/:id/:page_number' => "book_pages#show", :via => :get
  # NOTE: this is for the first version of the review API, will be deprecated soon
  match "incoming_data" => "incoming_datas#create", :method => :post


  match 'privacy' => 'pages#privacy'
  # the reader engine API
  match '/reader_engine_api' => "reader_engine_api#create", :via => :post
  match '/reader_engine_api/query' => "reader_engine_api#query", :via => :post  
  match '/terms-of-service' => 'pages#terms_of_service'
  get "bingo_experiments/create"

  # NOTE: this is for the first version of the review API, will be deprecated soon
  match "incoming_data" => "incoming_datas#create", :method => :post  
  match 'search' => 'search#show', :method => :post
  match 'search/autocomplete' => 'search#autocomplete'

  match 'show_review_form' => 'reviews#show_form'

  # current version of the web API
  match "/web_api" => "web_api#create", :via => :post
  match '/web_api/query' => "web_api#query", :via => :post

  match '/render_book_for_the_reader/:book_id' => "book_pages#render_book", :via => :get

  match '/inc_audiobook_downloaded_count/:id' => 'audiobooks#inc_downloaded_count'


  match '/audiobooks/:audiobook_id/reviews' => 'reviews#create'

  match '/reviews/create_rating' => 'reviews#create_rating'
  
  match '/pulse' => 'pulse#index', :as => :pulse
  
  resources :books, :only => :index do
    resources :reviews
  end

  resources :collections, :only => :show

  match "/:id/audiobooks/(:page)/(:sort)" => "collections#show_audiobooks", :as => :collection_audiobooks, :via => :get,   :constraints => { :page => /\d+/,
      :sort => /downloaded_count_asc|pretty_title_asc|downloaded_count_desc|pretty_title_desc|
      downloaded_count_asc!pretty_title_asc|pretty_title_asc!downloaded_count_asc|
      downloaded_count_desc!pretty_title_desc|pretty_title_desc!downloaded_count_desc|
      downloaded_count_desc!pretty_title_asc|pretty_title_desc!downloaded_count_asc|
      downloaded_count_asc!pretty_title_desc|pretty_title_asc!downloaded_count_desc/ }

  match "/:id/books/(:page)/(:sort)" => "collections#show_books", :as => :collection_books, :via => :get,   :constraints => { :page => /\d+/,
      :sort => /downloaded_count_asc|pretty_title_asc|downloaded_count_desc|pretty_title_desc|
      downloaded_count_asc!pretty_title_asc|pretty_title_asc!downloaded_count_asc|
      downloaded_count_desc!pretty_title_desc|pretty_title_desc!downloaded_count_desc|
      downloaded_count_desc!pretty_title_asc|pretty_title_desc!downloaded_count_asc|
      downloaded_count_asc!pretty_title_desc|pretty_title_asc!downloaded_count_desc/ }

  match "/:id/quotes/(:page)" => "collections#show_quotes"


  match "/:author_id/:id" => "seo#show_book", :as => :author_book, :via => :get
  match '/:id/quote/:quote_slug' => 'quotes#show', :as => :quote, :via => :get

  
  # == Notes and Highlights
  match "/:author_id/:book_id/highlights/:highlight_id" => "book_highlights#show", :as => :author_book_highlight, :via => :get

  # == final download pages, the ones that starts downloading the file immediately
  match '/:author_id/:id/download-mp3' => "audiobooks#download", :as => 'download_audiobook', :via => :get
  match "/:author_id/:id/download/:download_format" => "books#download", :as => 'download_book', :via => :get

  # for delivering the book file (automatic file downloading)
  match "/books/:id/download_in_format/:download_format" => "books#serve_downloadable_file",
        :as => 'serve_downloadable_file', :via => :get

  # for invoking the book reader
  match '/:id/page/:page_number' => "book_pages#show",
  :as => 'read_online', :via => :get
  
  match '/:id' => 'seo#show', :as => :seo, :via => :get
  root :to => 'pages#main'
end
