Rails.application.routes.draw do
  resources :municipalities
  resources :provinces

  root to: "provinces#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
