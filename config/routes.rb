Rails.application.routes.draw do
  resources :provinces, :path => '' 

  root to: "provinces#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
