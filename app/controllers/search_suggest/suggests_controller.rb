require_dependency 'search_suggest/application_controller'

module SearchSuggest
  class SuggestsController < ApplicationController
    def index
      @request = SearchSuggest::Request.prepare_request(params)
      respond_to do |format|
        format.html
        format.json { render json: @request, status: :ok }
      end
    end
  end
end
