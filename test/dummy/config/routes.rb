Rails.application.routes.draw do
  root to: "repositories#index"

  resources :repositories

  devise_for :users

  mount GitWit::Engine => "/"
end
