Classicly::Application.routes.draw do
  get "collections/show"

  resources :books , :only => :show do
    post :download, :on => :member    
  end

  resources :collections, :only => :show

  root :to => 'pages#main'
end
