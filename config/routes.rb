Classicly::Application.routes.draw do

  namespace 'admin' do
    root :to => "base#home"
    get 'admin_seo' => 'admin_seo#main'
    get 'admin_seo/:type' => 'admin_seo#admin_infoable', :as => 'admin_infoable'
    get 'admin_seo/:type/:id' => 'admin_seo#edit_seo', :as => 'edit_seo'
    get 'admin_seo/:type/:id/update_seo_info' => 'admin_seo#update_seo_info', :as => 'update_seo_info'
    get 'blog_posts/associate_book' => 'blog_posts#associate_book'

    # == Admin user related
    get 'logout' => 'admin_user_sessions#destroy', :as => 'logout'
    get 'sign_in' => 'admin_user_sessions#new', :as => 'sign_in'
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

  resources :mobile_app_upsell_redirects, :only => [:index]

  get 'reset_password' => "password_resets#new", :as => :new_reset_password
  get "reset_password/token/:id" => "password_resets#edit", :as => :reset_password
  get '/unsubscribe' => 'logins#unsubscribe', :as => :unsubscribe
  post 'mailchimp_callback' => 'logins#mailchimp_callback'

  # == Library
  get 'library' => 'libraries#show', :as => :library
  get 'library/handle_facebook_login' => 'libraries#handle_facebook_login', :as => :library_handle_facebook_login
  get 'books/:book_id/download_and_add_to_library/:download_format' => 'books#download_and_add_to_library', :as => :download_and_add_to_library

  # == Static-y Pages
  get "about" => "pages#about"
  get "terms-ipad" => "pages#terms_of_service_for_ipad"
  get "privacy-win8" => "pages#privacy_plain_text"
  get 'audiobook-collections' => 'pages#audio_collections'
  get 'audiobook-authors' => 'pages#audiobook_authors'
  get 'authors/(:page)' => 'pages#authors', :as => :authors
  get '/apps' => 'pages#apps'
  get 'blog' => 'blog#index', :as => :blog

  get 'collections/autocomplete' => 'collections#autocomplete'
  get 'collections/(:page)' => 'pages#collections', :as => :collections
  get '/dmca' => 'pages#dmca'
  get '/iphone' => 'pages#iphone'
  get '/ipad' => 'pages#ipad'
  get 'sitemap.xml' => redirect('/sitemap_index.xml.gz')

  # for delivering audiobook file
  get '/download_audiobook/:id' => 'audiobooks#serve_audiofile', :as => 'serve_audiofile', :via => :get

  # TODO: remove, this is only here for testing
  get '/reader/:id/:page_number' => "book_pages#show", :via => :get
  # NOTE: this is for the first version of the review API, will be deprecated soon
  get "incoming_data" => "incoming_datas#create", :method => :post


  get 'privacy' => 'pages#privacy'
  # the reader engine API
  get '/reader_engine_api' => "reader_engine_api#create", :via => :post
  get '/reader_engine_api/query' => "reader_engine_api#query", :via => :post  
  get '/terms-of-service' => 'pages#terms_of_service'
  get "bingo_experiments/create"

  # NOTE: this is for the first version of the review API, will be deprecated soon
  get "incoming_data" => "incoming_datas#create", :method => :post  
  get 'search' => 'search#show', :method => :post
  get 'search/autocomplete' => 'search#autocomplete'

  get 'show_review_form' => 'reviews#show_form'

  # current version of the web API
  get "/web_api" => "web_api#create", :via => :post
  get '/web_api/query' => "web_api#query", :via => :post

  get '/render_book_for_the_reader/:book_id' => "book_pages#render_book", :via => :get

  get '/inc_audiobook_downloaded_count/:id' => 'audiobooks#inc_downloaded_count'


  get '/audiobooks/:audiobook_id/reviews' => 'reviews#create'

  get '/reviews/create_rating' => 'reviews#create_rating'
  
  get '/pulse' => 'pulse#index', :as => :pulse
  
  resources :books, :only => :index do
    resources :reviews
  end

  resources :collections, :only => :show

  get "/:id/audiobooks/(:page)/(:sort)" => "collections#show_audiobooks", :as => :collection_audiobooks, :via => :get,   :constraints => { :page => /\d+/,
      :sort => /downloaded_count_asc|pretty_title_asc|downloaded_count_desc|pretty_title_desc|
      downloaded_count_asc!pretty_title_asc|pretty_title_asc!downloaded_count_asc|
      downloaded_count_desc!pretty_title_desc|pretty_title_desc!downloaded_count_desc|
      downloaded_count_desc!pretty_title_asc|pretty_title_desc!downloaded_count_asc|
      downloaded_count_asc!pretty_title_desc|pretty_title_asc!downloaded_count_desc/ }

  get "/:id/books/(:page)/(:sort)" => "collections#show_books", :as => :collection_books, :via => :get,   :constraints => { :page => /\d+/,
      :sort => /downloaded_count_asc|pretty_title_asc|downloaded_count_desc|pretty_title_desc|
      downloaded_count_asc!pretty_title_asc|pretty_title_asc!downloaded_count_asc|
      downloaded_count_desc!pretty_title_desc|pretty_title_desc!downloaded_count_desc|
      downloaded_count_desc!pretty_title_asc|pretty_title_desc!downloaded_count_asc|
      downloaded_count_asc!pretty_title_desc|pretty_title_asc!downloaded_count_desc/ }

  get "/:id/quotes/(:page)" => "collections#show_quotes"


  get "/:author_id/:id" => "seo#show_book", :as => :author_book, :via => :get
  get '/:id/quote/:quote_slug' => 'quotes#show', :as => :quote, :via => :get

  
  # == Notes and Highlights
  get "/:author_id/:book_id/highlights/:highlight_id" => "book_highlights#show", :as => :author_book_highlight, :via => :get

  # == final download pages, the ones that starts downloading the file immediately
  get '/:author_id/:id/download-mp3' => "audiobooks#download", :as => 'download_audiobook', :via => :get
  get "/:author_id/:id/download/:download_format" => "books#download", :as => 'download_book', :via => :get

  # for delivering the book file (automatic file downloading)
  get "/books/:id/download_in_format/:download_format" => "books#serve_downloadable_file",
        :as => 'serve_downloadable_file', :via => :get

  # for invoking the book reader
  get '/:id/page/:page_number' => "book_pages#show",
  :as => 'read_online', :via => :get
  
  get '/:id' => 'seo#show', :as => :seo, :via => :get
  root :to => 'pages#main'
end
