Rails.application.routes.draw do
  resources :public_keys


  root to: "repositories#index"

  resources :repositories

  devise_for :users

  mount GitWit::Engine => "/"
end
