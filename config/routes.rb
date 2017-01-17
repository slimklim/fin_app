Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :users, only: [:create, :update] do
    member do
      get :confirm_email
    end
  end
  resources :operations
  resources :sessions, only: [:create]
  resources :password_resets, except: [:index, :show, :destroy]


  root "operations#index"

  match '/signup',  to: 'users#new', via: 'get'
  match '/profile', to: 'users#show', via: 'get'
  match '/profile/edit', to: 'users#edit', via: 'get'

  match '/signin',  to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  match '/charts',  to: 'operations#charts', via: 'post'
  match '/filter',  to: 'operations#filter', via: 'post'

  match '/welcome',  to: 'static#welcome', via: 'get'
  match '/help',  to: 'static#help', via: 'get'



  # match '*path' must be last of routes
  match '*path' => redirect('/'), via: :get
end
