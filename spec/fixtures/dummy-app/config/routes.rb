Rails.application.routes.draw do
  resources :users

  resources :testing do
    collection do
      get :default_component
      get :performance
      get :custom_component
    end
  end
end
