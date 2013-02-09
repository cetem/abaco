Abaco::Application.routes.draw do
  
  resources :settings

  resources :outflows do
    collection do
      get :autocomplete_for_operator
      get :show_pay_pending_shifts
      put :pay_shifts
    end
  end

  devise_for :users
  
  resources :users do
    member do
      get :edit_profile
      put :update_profile
    end
  end
  
  root to: redirect('/users/sign_in')
end
