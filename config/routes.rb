Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post '/register', to: 'auth#register'
      post '/login', to: 'auth#login'
      get '/me', to: 'auth#me'
      resources :orders, only: [:index, :show, :create]
      post '/stripe_webhook', to: 'orders#stripe_webhook'
      resources :products do
        resources :reviews, only: [:index, :create, :show, :update, :destroy]
      end
      get '/admin/orders', to: 'orders#admin_index'
      patch '/orders/:id/complete', to: 'orders#complete'
      resource :cart, only: [:show] do
        post 'add_item', to: 'carts#add_item'
        delete 'remove_item', to: 'carts#remove_item'
        post 'abandon', to: 'carts#abandon'
        post 'convert_to_order', to: 'carts#convert_to_order'
      end
      get '/admin/carts/abandoned', to: 'carts#admin_abandoned'
      get '/admin/stats/sales', to: 'stats#sales'
      get '/admin/stats/abandoned_carts', to: 'stats#abandoned_carts'
      get '/admin/stats/user_stats', to: 'stats#user_stats'
      resources :blog_posts
    end
  end


  # Defines the root path route ("/")
  # root "posts#index"
end
