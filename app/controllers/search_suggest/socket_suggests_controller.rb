require_dependency 'search_suggest/application_controller'

module SearchSuggest
  class SocketSuggestsController < WebsocketRails::BaseController
    def initialize_session
      controller_store[:suggests] = []
      controller_store[:words] = []
    end

    def suggests_get
      @response = SearchSuggest::Request.process_request(message, controller_store[:words], controller_store[:suggests])
      controller_store = SearchSuggest::Request.set_controller_store!(self.controller_store, @response)
      @response[:words] = [] # Нет нужды пересылать туда-обратно большие массивы

      if @response[:allow]
        trigger_success @response
      else
        trigger_failure @response
      end
    end
  end
end
