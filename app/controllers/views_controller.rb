class ViewsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:fetch]

  # PUT /page_views
  def fetch
    @request_data = request.body.read
    @search_results = ES.do_search @request_data
    render :json => @search_results
  end
end
