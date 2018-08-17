require 'rails_helper'

RSpec.describe ViewsController, type: :controller do
  describe 'GET /es_health' do
    it 'talks to elastic search and gets 200 response' do
      get :es_health
      expect(assigns(:health).status).to be 200
    end
  end

  describe 'GET to /page_views' do
    let(:headers) { {"CONTENT_TYPE" => "application/json" } }
    let(:body) {
      '{
        "urls": [
          "http://www.news.com.au"
        ],
        "before": "2017-06-04T14:00:00.000Z",
        "after": "2017-06-01T14:00:00.000Z",
        "interval": "15m"
      }'
    }
    let(:query_obj) {
      {
        query: {
          bool: {
            must: [
              {
                terms: {
                  page_url: [
                    "http://www.news.com.au"
                  ]
                }
              },
              {
                range: {
                  derived_tstamp: {
                    gte: "2017-06-01T14:00:00.000Z",
                    lte: "2017-06-04T14:00:00.000Z"
                  }
                }
              }
            ]
          }
        },
        aggs: {
          first_agg: {
            date_histogram: { field: "derived_tstamp", interval: '15m' },
            aggs: {
              sub_agg: { 
                terms: { field: "page_url"  }
              }
            }
          }
        }
      }
    }
    before {
      get 'fetch', :body => body, as: :json
    }

    it 'receives data from the request' do
      request_data = assigns(:request_data)
      
      expect(request_data).to eq body
    end

    it 'formats elastic search request' do
      built_query = assigns(:query_obj)

      expect(built_query).to eq query_obj
    end

    it 'performs search successfully' do
      total_shards = assigns(:search_results)['_shards']['total']
      expect(total_shards).to eq 58
    end

    it 'responds with content type application/json' do
      expect(response.header['Content-Type']).to include 'application/json'
    end

    it 'responds with json body' do
      total_shards = assigns(:search_results)['_shards']['total']
      json_body = JSON.parse(response.body)
      expect(json_body['_shards']['total']).to eq total_shards
    end
  end
end

# 
#  "properties": {
#     "br_name": {
#       "type": "keyword"
#     },
#     "derived_tstamp": {
#       "type": "date"
#     },
#     "dvce_type": {
#       "type": "keyword"
#     },
#     "geo_country": {
#       "type": "keyword"
#     },
#     "geo_location": {
#       "type": "geo_point"
#     },
#     "geo_region_name": {
#       "type": "keyword"
#     },
#     "geo_zipcode": {
#       "type": "keyword"
#     },
#     "os_name": {
#       "type": "keyword"
#     },
#     "page_referrer": {
#       "type": "keyword"
#     },
#     "page_title": {
#       "type": "keyword"
#     },
#     "page_url": {
#       "type": "keyword"
#     },
#     "page_urlhost": {
#       "type": "keyword"
#     },
#     "page_urlpath": {
#       "type": "keyword"
#     },
#     "refr_medium": {
#       "type": "keyword"
#     },
#     "refr_source": {
#       "type": "keyword"
#     },
#     "user_fingerprint": {
#       "type": "keyword"
#     },
#     "user_ipaddress": {
#       "type": "keyword"
#     }
#   }


# ELASTIC SEARCH TEMPLATE
# GET /_search
# {
#   "query": {
#     "bool": {
#       "must": { "terms": { "page_url": ["www.news.com.au","www.heraldsun.com.au"] }},
#       "must": {
#         "range": {
#         "derived_tstamp" : {
#           "gte": "01/06/2017",
#           "lte": "3/06/2017",
#           }
#         }
#       }
#     }
#   },
#   "aggs" : {
#     "first_agg": {
#       "date_histogram" : { "field" : "derived_tstamp", "interval" : "15m" },
#       "aggs": {
#         "sub_agg": { 
#           "terms": { "field": "page_url"  }
#         }
#       }
#     }
#   }
# }