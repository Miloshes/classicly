Classicly::Application.routes.draw do
  resources :books , :only => :show

  root :to => 'pages#main'
end
