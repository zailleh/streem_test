Rails.application.routes.draw do
  # get '/page_views' => 'views#fetch'
  put '/page_views' => 'views#fetch'
  root to: 'pages#home'
  get '/test' => 'pages#home'
end
