require 'rails_helper'

RSpec.describe ViewsController, type: :controller do

  describe 'PUT to /page_views' do
    let(:headers) { {"CONTENT_TYPE" => "application/json" } }
    let(:body) {
      '{
        "urls": [
          "http://www.news.com.au/technology/environment/trump-pulls-us-out-of-paris-climate-agreement/news-story/f5c30a07c595a10a81d67611d0515a0a"
        ],
        "before": "2017-06-04T14:00",
        "after": "2017-06-01T14:00",
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
                    "http://www.news.com.au/technology/environment/trump-pulls-us-out-of-paris-climate-agreement/news-story/f5c30a07c595a10a81d67611d0515a0a"
                  ]
                }
              },
              {
                range: {
                  derived_tstamp: {
                    gte: "2017-06-01T14:00",
                    lte: "2017-06-04T14:00",
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
                date_histogram: { field: "derived_tstamp", interval: '15m' }
              }
            }
          }
        }
      }
    }
    before {
      put 'fetch', :body => body, as: :json
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
      json_body = JSON.parse(response.body)
      expect(json_body['hits']['total']).to eq 242498
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