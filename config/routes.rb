Rails.application.routes.draw do
  get '/page_views' => 'views#fetch'
  get '/health' => 'views#es_health'
end
