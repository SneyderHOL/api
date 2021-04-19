Rails.application.routes.draw do
  #get '/articles', to: 'articles#index'
  # post '/login', to: 'access_tokens#create'
  post 'login', to: 'access_tokens#create'
  resources :articles, only: [:index, :show]
end
