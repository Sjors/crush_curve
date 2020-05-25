Rails.application.routes.draw do
  match '(*any)', to: redirect(subdomain: ''), via: :all, constraints: {subdomain: 'www'}

  resources :provinces, :path => '' do
    scope format: true, constraints: { format: /rss/ } do
        resources :municipalities, :path => ''
    end
  end

  root to: "provinces#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
