Rails.application.routes.draw do
  require 'sidekiq/web'

  Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_token]
  Sidekiq::Web.set :sessions, Rails.application.config.session_options
  mount Sidekiq::Web => '/sidekiq'

  get 'operators/:id' => 'operators#show', as: 'operator'
  get 'operators' => 'operators#index', as: 'operators'
  get 'operators/:id/new_shift' => 'operators#new_shift',
    as: 'new_operator_shift'
  post 'operators/:id/create_shift' => 'operators#create_shift',
    as: 'create_operator_shift'
  get 'operators/:operator_id/shifts/:id/edit' => 'operators#edit_shift',
    as: 'edit_operator_shift'
  patch 'operators/:operator_id/shifts/:id' => 'operators#update_shift',
    as: 'update_operator_shift'
  get 'downloads' => 'application#downloads', as: 'downloads'

  resources :settings

  resources :outflows do
    collection do
      get :autocomplete_for_operator
      get :show_all_pay_pending_shifts
      patch :pay_shifts
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
