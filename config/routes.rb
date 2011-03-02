Classicly::Application.routes.draw do
  resources :download_formats
  resources :books , :only => :show

  root :to => 'pages#main'
end
