Abaco::Application.routes.draw do
  get 'operators/:id' => 'operators#show', as: 'operator'
  get 'operators' => 'operators#index', as: 'operators'
  get 'operators/:id/new_shift' => 'operators#new_shift',
    as: 'new_operator_shift'
  post 'operators/:id/create_shift' => 'operators#create_shift',
    as: 'create_operator_shift'

  resources :settings

  resources :outflows do
    collection do
      get :autocomplete_for_operator
      get :show_pay_pending_shifts
      get :show_all_pay_pending_shifts
      patch :pay_shifts
    end
  end

  devise_for :users

  resources :users do
    member do
      get :edit_profile
      patch :update_profile
    end
  end

  root to: 'outflows#index'
end
