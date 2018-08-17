class ViewsController < ApplicationController
  def es_health
    @health = health_check
  end

  def fetch
    #get body from request
    @request_data = request.body.read
    @query_obj = build_query_obj(@request_data)
    @search_results = do_search 'events', @query_obj
    # search_json = JSON::parse(@request_data)
    render :json => @search_results
  end

  private
    def get_es_client
      Elasticsearch::Client.new hosts: [
      { host: 'test.es.streem.com.au',
        port: '9200',
        user: 'elastic',
        password: 'streem',
        scheme: 'http'
      } ]
    end

    def health_check
      client = get_es_client
      client.perform_request 'GET', '_cluster/health'
    end 

    def do_search index, search
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
                    lte: request_data['before']
                  }
                }
              }
            ]
          }
        },
        aggs: {
          first_agg: {
            date_histogram: { field: "derived_tstamp", interval: request_data['interval'] },
            aggs: {
              sub_agg: { 
                terms: { field: "page_url"  }
              }
            }
          }
        }
      }
    end
end
