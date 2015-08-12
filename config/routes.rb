SearchSuggest::Engine.routes.draw do
  root to: 'suggests#index'
  match '/' => 'suggests#index', via: [:get, :post]
end
