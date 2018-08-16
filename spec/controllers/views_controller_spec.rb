require 'rails_helper'

RSpec.describe ViewsController, type: :controller do
  when 'GET to /page_views' do

    it '' do

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
#       "must": { "terms": { "page_urlhost": ["www.news.com.au","www.heraldsun.com.au"] }},
#       "must": {
#         "range": {
#         "derived_tstamp" : {
#           "gte": "01/06/2017",
#           "lte": "3/06/2017",
#           "format": "dd/MM/yyyy||yyyy"
#           }
#         }
#       }
#     }
#   },
#   "aggs" : {
#     "my_buckets" : {
#       "composit": {
#         "sources": [
#             { "intervals": { "date_histogram" : { "field" : "derived_tstamp", "interval" : "15m" } } },
#             { "urls": { "terms": { "field": "page_url"  } } }
#         ]
#       }
#     }
#   }
# }