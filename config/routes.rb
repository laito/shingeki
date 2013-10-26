Shingeki::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  namespace :api, :defaults => {:format => :json} do
    resources :users
    resources :signins
    resources :gcms
    resources :events
    post '/events', to: 'events#index'
    post '/accept/:id', to: 'events#accept'
    post '/optout/:id', to: 'events#optout'
    post '/approve/:id', to: 'events#approve'
    post '/cancel/:id', to: 'events#cancel'
    get '/myevents', to: 'events#myevents'
    post '/myevents', to: 'events#myevents'
    post '/gcm', to: 'gcms#register'
    get '/gcm', to: 'gcms#register'
    post '/signin', to: 'signins#create'
    get '/signin', to: 'signins#create'
    post '/currentuser', to: 'users#currentuser'
    get '/currentuser', to: 'users#currentuser'
    post '/users/:id', to: 'users#show'
    get '/users/:id', to: 'users#show'
    get '/gcm', to: 'gcms#register'
    get '/signin', to: 'signins#create'
    get '/currentuser', to: 'users#currentuser'
    get '/users/:id', to: 'users#show'
  end

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
