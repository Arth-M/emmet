Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # root path with top_five recipes
  root "recipes#top_five"
  # show for a recipe
  resources :recipes, only: %i[show], as: :recipe
  # result of search through found_recipes
  get "your-recipes", to: "recipes#found_recipes", as: :found_recipes

end
