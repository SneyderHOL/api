Rails.application.routes.draw do
  #get '/articles', to: 'articles#index'
  # post '/login', to: 'access_tokens#create'
  post 'login', to: 'access_tokens#create'
  delete 'logout', to: 'access_tokens#destroy'
  resources :articles, only: [:index, :show]
end
