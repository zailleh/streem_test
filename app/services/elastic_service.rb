class ElasticService
  include Singleton

  def initialize
    @client = get_es_client
  end

  def health_check
    @client.perform_request 'GET', '_cluster/health'
  end 

  def do_search request_data
    query = build_query_obj request_data
    @client.search body: query
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
          terms: { 
            field: "page_url",
            min_doc_count: 1
          },
          aggs: {
            sub_agg: { 
              date_histogram: { field: "derived_tstamp", interval: request_data['interval'] }
            }
          }
        }
      }
    }
  end

  private 
    def get_es_client
      Elasticsearch::Client.new hosts: [
        { host: ENV.fetch("STREEM_ES_TEST_HOST"),
          port: '9200',
          user: ENV.fetch("STREEM_ES_TEST_U"),
          password: ENV.fetch("STREEM_ES_TEST_P"),
          scheme: 'http'
        }
      ]
    end
end