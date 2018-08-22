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
    
    before {
      put 'fetch', :body => body, as: :json
    }

    it 'receives data from the request' do
      request_data = assigns(:request_data)
      
      expect(request_data).to eq body
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