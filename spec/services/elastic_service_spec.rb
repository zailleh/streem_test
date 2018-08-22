require 'rails_helper'

RSpec.describe ElasticService do
  let(:es) { ElasticService.instance }
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
          terms: { 
            field: "page_url",
            min_doc_count: 1 
          },
          aggs: {
            sub_agg: { 
              date_histogram: { field: "derived_tstamp", interval: '15m' }
            }
          }
        }
      }
    }
  }
  let(:request_body) {
  '{
      "urls": [
        "http://www.news.com.au/technology/environment/trump-pulls-us-out-of-paris-climate-agreement/news-story/f5c30a07c595a10a81d67611d0515a0a"
      ],
      "before": "2017-06-04T14:00",
      "after": "2017-06-01T14:00",
      "interval": "15m"
    }'
  }

  it "creates an ES client that connects to health check ok" do
    expect(es.health_check.status).to eq 200;
  end

  it 'formats elastic search request' do
    
    built_query = es.build_query_obj request_body

    expect(built_query).to eq query_obj
  end

  it 'performs search successfully' do
    search_results = es.do_search request_body
    total_shards = search_results['_shards']['total']
    expect(total_shards).to eq 58
  end
end