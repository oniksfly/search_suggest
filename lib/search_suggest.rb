require 'search_suggest/engine'
require 'slim'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'websocket-rails'

module SearchSuggest
  RESULTS_COUNT = [10, 30, 50, 100, 500, 1000]
  MIN_REQUEST_LENGTH = 3
  WEBSOCKET_STANDALONE = true # Required Redis
  WEBSOCKET_PORT = '3001'
  WEBSOCKET_REDIS_OPTIONS = {
      host: 'localhost',
      port: '6379'
  }
  WEBSOCKET_SERVER_PATH = "localhost:#{ WEBSOCKET_PORT }/websocket"
end
