const makeChartData = function(data) {
  // template for dataset
  // dataset: [{
  //   stack: stack id,
  //     label: "Page Views",
  //       data: [12, 19, 3, 5, 2, 3], // data is each views in each interval
  // }]

  const colors = [
    "rgb(169, 50, 38)",
    "rgb(202, 111, 30)",
    "rgb(212, 172, 13)",
    "rgb(36, 113, 163)",
    "rgb(136, 78, 160)",
    "rgb(22, 160, 133)"
  ];

  // create data object that we'll return
  const chartData = { 
    labels: [],
    datasets: [], 
  };

  // array of 'URLS" -- eg stacked parts
  // create a stack for each sub agg for chart.js
  const urls = data.aggregations.first_agg.buckets;


  // set labels for intervals
  // TODO: Convert this to human-friendly timestamp
  chartData.labels = urls[0].sub_agg.buckets.map( (b) => b.key_as_string) 

  // create one dataset per URL
  chartData.datasets = urls.map( (bucket) => {
    // viewsPerInterval are the columns
    const viewsPerInterval = bucket.sub_agg.buckets.map(
      (sub_bucket) => sub_bucket.doc_count
    )

    return {
      stack: 1,
      label: bucket.key,
      backgroundColor: colors.shift(),
      data: viewsPerInterval,
    }
  })

  return chartData;
}

const makeChart = function(data, chart) {
  const canvas = document.getElementById("myChart").cloneNode();
  document.getElementById("myChart").remove();
  document.getElementsByClassName('chart-area')[0].appendChild(canvas);
  const ctx = document.getElementById("myChart").getContext("2d");
  
  const chartData = makeChartData(data)

  const pageViewChart = new Chart(ctx, {
    type: "bar",
    data: chartData,
    options: {
      legend: {
        display: true,
        position: "bottom",
        fullWidth: false
      },
      scales: {
        yAxes: [
          {
            stacked: true,
            scaleLabel: {
              display: true,
              labelString: "Page Views"
            }
          }
        ],
        xAxes: [
          {
            scaleLabel: {
              display: true,
              labelString: "Time"
            }
          }
        ]
      }
    }
  });
  
  return pageViewChart;
}

document.addEventListener("DOMContentLoaded", () => {
  const form = new Vue({
    el: "#page-view",
    data: {
      urls: [],
      before: "2017-06-04T14:00", // default
      after: "2017-06-01T14:00", // default
      interval: "15m" // default
    },
    methods: {
      fetchResults() {
        // console.log(JSON.stringify(this.$data));
        fetch("/page_views", {
          method: "PUT",
          cache: "no-cache",
          headers: {
            "Content-Type": "application/json; charset=utf-8"
          },
          redirect: "follow",
          referrer: "no-referrer",
          body: JSON.stringify(this.$data)
        })
          .then(response => response.json())
          .then(data => {
            makeChart(data);
          });
      }
    }
  });
});