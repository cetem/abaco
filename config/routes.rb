Rails.application.routes.draw do
  require 'sidekiq/web'

  Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_token]
  Sidekiq::Web.set :sessions, Rails.application.config.session_options
  mount Sidekiq::Web => '/sidekiq'

  # get 'operators/:id' => 'operators#show', as: 'operator'
  # get 'operators' => 'operators#index', as: 'operators'

  resources :operators, only: [:index, :show] do
    patch :import, on: :collection
    member do
      get :new_shift
      post :create_shift
    end
    # resources :shifts, only: [:show, :edit]
  end

  get 'operators/:operator_id/shifts/:id/edit' => 'operators#edit_shift',
    as: 'edit_operator_shift'
  patch 'operators/:operator_id/shifts/:id' => 'operators#update_shift',
    as: 'update_operator_shift'

  get 'downloads' => 'application#downloads', as: 'downloads'

  resources :settings
  resources :providers
  resources :boxes

  # Outflow history urls
  get 'outflows/:id' => 'movements#show'

  resources :movements do
    collection do
      get :autocomplete_for_association
      get :autocomplete_for_provider
      get :show_all_pay_pending_shifts
      patch :pay_shifts
    end
    member do
      delete :revoke
    end
  end

  match 'reports/monthly_info' => 'reports#monthly_info', via: [:get, :post]
  get 'reports/incentives_between' => 'reports#incentives_between'
  get 'reports/retroactive_between' => 'reports#retroactive_between'

  devise_for :users

  resources :users do
    member do
      get :edit_profile
      patch :update_profile
    end
  end

  root to: 'application#root_redirector'
end
