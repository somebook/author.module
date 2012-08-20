Author::Engine.routes.draw do
  resources :shard_users do
    collection do
      post 'add'
    end
    member do
      delete 'revoke'
    end
  end
  resources :shard_languages do
    resources :accounts do
      resources :terminals
      member do
        get 'ga'
      end
    end

    get 'link_service'
  end
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
  resources :api_keys

  match 'settings' => 'settings#index', as: :settings
  match 'picasa' => 'picasa#index', as: :picasa
  match 'picasa/destroy' => 'picasa#destroy', as: :picasa_destroy
  match 'set_my_shard/:shard_id' => 'space#set_my_shard', as: :set_my_shard
  root to: 'index#index'
end
