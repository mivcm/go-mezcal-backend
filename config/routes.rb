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
      resources :orders, only: [:index, :show, :create] do
        post '/capture', to: 'orders#capture_paypal_order', on: :member
      end
      post '/orders/paypal/:paypal_order_id/capture', to: 'orders#capture_paypal_order'
      post '/stripe_webhook', to: 'orders#stripe_webhook'
      get '/admin/orders', to: 'orders#admin_index'
      patch '/orders/:id/complete', to: 'orders#complete'
      get '/admin/orders/:id', to: 'orders#admin_show'
      patch '/admin/orders/:id/status', to: 'orders#admin_update_status'
      resources :products do
        collection do
          get 'featured', to: 'products#high_rated_products'
        end
        resources :reviews, only: [:index, :create, :show, :update, :destroy]
      end
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
      get '/site_settings/show_hero_image', to: 'site_settings#show_hero_image'
      patch '/admin/site_settings/update_hero_image', to: 'site_settings#update_hero_image'
      get '/site_settings/show_our_philosophy_image', to: 'site_settings#show_our_philosophy_image'
      patch '/admin/site_settings/update_our_philosophy_image', to: 'site_settings#update_our_philosophy_image'
      resources :blog_posts
      resources :site_settings, only: [] do
        collection do
          get 'image', to: "site_settings#show_image"
          patch 'image', to: "site_settings#update_image"
        end
      end
      # Contact messages
      post '/contact_messages', to: 'contact_messages#create'
      get '/admin/contact_messages', to: 'contact_messages#index'
      get '/admin/contact_messages/:id', to: 'contact_messages#show'
      patch '/admin/contact_messages/:id/mark_as_read', to: 'contact_messages#mark_as_read'
      delete '/admin/contact_messages/:id', to: 'contact_messages#destroy'
      get '/admin/contact_messages/stats', to: 'contact_messages#stats'
    end
  end


  # Defines the root path route ("/")
  # root "posts#index"
end
