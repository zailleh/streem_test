class ViewsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:fetch]

  # PUT /page_views
  def fetch
    @request_data = request.body.read
    @query_obj = build_query_obj(@request_data)
    @search_results = do_search @query_obj

    render :json => @search_results
  end

  private
    def get_es_client
      Elasticsearch::Client.new hosts: [
      { host: 'test.es.streem.com.au',
        port: '9200',
        user: ENV.fetch("STREEM_ES_TEST_U"),
        password: ENV.fetch("STREEM_ES_TEST_P"),
        scheme: 'http'
      } ]
    end

    def health_check
      client = get_es_client
      client.perform_request 'GET', '_cluster/health'
    end 

    def do_search search
      client = get_es_client
      client.search body: search
    end

    def build_query_obj request_data
      request_data = JSON.parse(request_data)
      {
        query: {
          bool: {
            must: [
              {
                terms: {
                  page_url: request_data['urls']
                }
              },
              {
                range: {
                  derived_tstamp: {
                    gte: request_data['after'],
                    lte: request_data['before'],
                    format: "yyyy-MM-dd'T'HH:mm"
                  }
                }
              }
            ]
          }
        },
        aggs: {
          first_agg: {
            terms: { field: "page_url"  },
            aggs: {
              sub_agg: { 
                date_histogram: { field: "derived_tstamp", interval: request_data['interval'] }
              }
            }
          }
        }
      }
    end
end
