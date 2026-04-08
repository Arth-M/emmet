Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "dashboard#index"
  get '/home/pav/:id', to: 'dashboard#pav_detail', as: :pav_detail
  get '/incidents', to: 'incidents#index', as: :incidents_index
  get '/fills', to: 'sensors#index', as: :sensors_index
  resources :incidents, only: [:index] do
    member do
      patch :toggle_resolved
    end
  end

end
