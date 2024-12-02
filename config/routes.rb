Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/swagger'
  mount Rswag::Api::Engine => '/swagger'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      post 'sessions', to: 'sessions#create'
      resources :users do 
        collection do
          get 'my_profile' , to: 'profile'
        end
      end
      resources :surveys do
        member do 
          post :mark_inactive
          post :mark_active
        end
        resources :responses, only: [:create,:index]
        resources :questions, only: [:index, :create, :show, :destroy]
      end
    end
  end
end