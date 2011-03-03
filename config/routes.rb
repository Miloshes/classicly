Classicly::Application.routes.draw do
  resources :books , :only => :show do
    post :download, :on => :member    
  end
  root :to => 'pages#main'
end
