Rails.application.routes.draw do
  resources :before_followers
  devise_for :users, controllers: { :omniauth_callbacks => "omniauth_callbacks" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'static_pages#info'
  
  # 静的ページ
  get 'static_pages/info'
  get 'static_pages/update'

  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  resources :followers do
    member do
      get 'update_followers'
      get 'update_friends'
    end
    collection do
      get 'remove_index'
    end
  end

  resources :tops
end
