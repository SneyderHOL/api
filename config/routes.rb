Rails.application.routes.draw do
  #get '/articles', to: 'articles#index'
  resources :articles, only: [:index, :show]
end
