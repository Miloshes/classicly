Classicly::Application.routes.draw do
  resources :download_formats

  root :to => 'pages#main'
end
