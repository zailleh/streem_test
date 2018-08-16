Rails.application.routes.draw do
  get '/page_views' => 'views#fetch'
end
