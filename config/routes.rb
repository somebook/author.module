Author::Engine.routes.draw do
  resources :posts, except: [:index] do
    collection do
      get 'blog', as: :blog
      get 'news', as: :news
    end
    resources :contents do
      resources :comments, constraints: { id: /\w+/} do
        member do
          get 'delete'
          get 'approve'
          get 'reject'
          get 'junk'
        end
      end
    end
    get 'publish'
    get 'sticky'
  end
  resources :publication_patterns
  resources :static_pages do
    resources :contents
  end
  resources :events
  resources :albums do
    collection do
      get 'authorize'
      get 'sync'
    end
    get 'hidden'
    resources :photos do
      collection do
        get 'sync'
      end
    end
  end
  resources :videos do
    member do
      get 'upload'
      get 'uploaded'
    end
    collection do
      get 'syncronize'
    end
  end
  resources :audio_albums do
    resources :audios
  end
  resources :social_drafts do
    member do
      get 'import'
    end
  end
  namespace :settings do
    resources :api_keys, except: [:index]
    resources :shard_languages
    resources :accounts do
      resources :terminals
      member do
        get 'ga'
        get 'terms'
      end
    end
    get 'link_service'
    resources :shard_users do
      collection do
        post 'add'
      end
      member do
        delete 'revoke'
      end
    end
    resource :amazon_setting
    match 'picasa/destroy' => 'picasa#destroy', as: :picasa_destroy
  end

  match 'settings' => 'settings#index', as: :settings
  match 'set_my_shard/:shard_id' => 'space#set_my_shard', as: :set_my_shard
  # devise_for :users,
  #   path_names: { sign_in: "login", sign_out: "logout", sign_up: "signup" },
  #   sign_out_via: [:post, :delete, :get],
  #   controllers: { omniauth_callbacks: "users/omniauth_callbacks", registrations: "users/registrations" }
  root to: 'index#index'
end
