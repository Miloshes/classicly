Classicly::Application.routes.draw do
  resources :books , :only => :show do
    post :download, :on => :member    
  end

  match "/:id" => "collections#show", :as => 'collection'

  root :to => 'pages#main'
end
