Rails.application.routes.draw do

  mount SearchSuggest::Engine => "/search_suggest"
end
