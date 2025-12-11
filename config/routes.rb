Rails.application.routes.draw do
  resource :session, only: [ :new, :create, :destroy ]
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :projects do
    resources :tasks, only: [ :new, :create, :update, :show ] do
      member do
        patch :request_review
        patch :cancel_review
        patch :mark_complete
        patch :assign_to_me
      end
      resources :comments, only: [ :create, :update, :destroy ]
    end
    resources :collaborators, only: [ :show, :edit, :update, :destroy, :create ]
  end

  # Registration routes
  resources :users, only: [ :new, :create, :edit, :update ]

  # Defines the root path route ("/")
  root "home#index"
end
