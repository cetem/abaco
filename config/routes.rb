Abaco::Application.routes.draw do
  
  resources :outflows do
    collection do
      get :autocomplete_for_operator
    end
  end

  devise_for :users
  
  resources :users do
    member do
      get :edit_profile
      put :update_profile
    end
  end
  
  root to: 'users#index'
end
