require 'erb'
require 'json'
require './fx.rb'
require './myarray.rb'

fx = FX.new
fx.set

pairs = fx.fxes.keys
results = {}
pairs.each_with_index do |pair1, i|
  pairs.each_with_index do |pair2, j|
    next if i >= j

    nenri1 = fx.fxes[pair1]['nenri']
    nenri2 = fx.fxes[pair2]['nenri']
    sd1    = fx.fxes[pair1]['sd']
    sd2    = fx.fxes[pair2]['sd']
    arr1   = fx.fxes[pair1]['profit'].map{|date, profit| profit }
    arr2   = fx.fxes[pair2]['profit'].map{|date, profit| profit }
    cor    = r(arr1, arr2) 

    pair1_to_pair2 = "#{pair1}-#{pair2}"
    results[pair1_to_pair2] = []
    0.step(100, 10) do |w|
      nenri = w.to_f / 100 * nenri1 + (100 - w).to_f / 100 * nenri2
      var   = (w.to_f / 100 * sd1) ** 2 +
              ((100 - w).to_f / 100 * sd2) ** 2 +
              (w.to_f / 100 * (100 - w).to_f / 100 * cor * sd1 * sd2) * 2
      sd    = Math.sqrt(var)
      sharp = nenri / sd
      # printf "%s-%s@%3d:%3d,%6.1f,%6.1f,%6.2f\n", pair1, pair2, w, 100 - w, nenri, sd, sharp
      results["#{pair1}-#{pair2}"] << {
        'pair1' => pair1,
        'pair2' => pair2,
        'w1'    => w,
        'w2'    => 100 - w,
        'nenri' => nenri.round(2),
        'sd'    => sd.round(2),
        'sharp' => sharp.round(2)
      }
    end
    # puts "#{i}:#{pair1} #{j}:#{pair2}"
  end
end

# pp results.to_json

erb = ERB.new(DATA.read)
open('aiu.html', 'w'){|f| f.write erb.result }

__END__

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title></title>
  <style>
    .invisible{
      // visibility: hidden;
      display: none;
    }
    .visible{
      display: table-row;
      // visibility: visible;
    }
  </style>
</head>
<body>
  <canvas id="frontier"></canvas>
  <form id="frontier_pair1">
    <h3>通貨ペア1(ポートフォリオ比率)</h3>
    <% fx.fxes.keys.each do |pair| %>
      <input type="radio" name="frontier_pair1" value="<%= pair %>"><%= pair %>
    <% end %>
  </form>
  <form id="frontier_pair2">
    <h3>通貨ペア2(ポートフォリオ比率)</h3>
    <% fx.fxes.keys.each do |pair| %>
      <input type="radio" name="frontier_pair2" value="<%= pair %>"><%= pair %>
    <% end %>
  </form>

  <table>
    <tr>
      <th>通貨ペア1</th>
      <th>通貨ペア2</th>
      <th>比率1(%)</th>
      <th>比率2(%)</th>
      <th>年利(%)</th>
      <th>標準偏差(%)</th>
      <th>シャープレシオ(%)</th>
    </tr>
    <%
      results.keys.each do |pair1_to_pair2|
        results[pair1_to_pair2].each do |row|
    %>
      <tr class="<%= pair1_to_pair2 %> row_frontier invisible">
        <td><%= row['pair1'] %></td>
        <td><%= row['pair2'] %></td>
        <td><%= row['w1'] %></td>
        <td><%= row['w2'] %></td>
        <td><%= row['nenri'] %></td>
        <td><%= row['sd'] %></td>
        <td><%= row['sharp'] %></td>
      </tr>
    <%
        end
      end
    %>
  </table>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.24.0/moment.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
  <script>
    var json_frontier = <%= results.to_json %>
  </script>
  <script>
    var ctx = document.getElementById('frontier').getContext('2d')
    var cfg = {
      type: 'scatter',
      data: {
        datasets: [
          {
            data: []  // for all points
          },
          {
            pointBorderColor: 'blue',
            pointBackgroundColor: 'blue',
            data: [],  // for pair1 - pair2
          }
        ]
        /*
        datasets: [
          {
            lable: 'aiu1',
            data: [
              {x: 1, y: 1},
            ],
          },
          {
            lable: 'aiu2',
            data: [
              {x: 2, y: 3},
            ],
          },
          {
            lable: 'aiu3',
            data: [
              {x: 3, y: 5},
            ],
          },
        ]
        */
      },
      options: {
        scales: {
          xAxes: [{
            ticks: {
              min: 0
            }
          }],
        },
        legend: {
          display: false,
        }
      }
    }
    var chart = new Chart(ctx, cfg)

    // plot all point
    chart.config.data.datasets[0].data = get_frontier_all_points()
    chart.config.data.datasets[1].data = []
    chart.update()

    radios_frontier = ['frontier_pair1', 'frontier_pair2']
    radios_frontier.forEach(function(radio_frontier){
      document.getElementById(radio_frontier).addEventListener('click', function(){
        chart.config.data.datasets[1].data = get_frontier_pair1_to_pair2_points()
        chart.update()

        display_table_row()
      })
    })

    function get_frontier_all_points(){
      let data = []
      for(let key in json_frontier){
        for(let i in json_frontier[key]){
          pair1 = json_frontier[key][i]['pair1']
          pair2 = json_frontier[key][i]['pair2']
          nenri = json_frontier[key][i]['nenri']
          sd    = json_frontier[key][i]['sd']
          data.push({x: sd, y: nenri})
        }
      }
      return data
    }

    function get_frontier_pair1_to_pair2_points(){
      let [pair1, pair2] = get_checked_pairs()
      let data = []
      let pattern1 = `${pair1}-${pair2}`
      let pattern2 = `${pair2}-${pair1}`
      let pattern  = ''

      // check exist data(invalid radio button)
      if(json_frontier[pattern1] != null){
        pattern = pattern1
      }
      if(json_frontier[pattern2] != null){
        pattern = pattern2
      }
      if(pattern != ''){
        points = json_frontier[pattern]
        for(let i = 0; i < points.length; i++){
          data.push({x: points[i]['sd'], y: points[i]['nenri']})
        }
      }
      return data
    }

    function get_checked_pairs(){
      frontier_pairs1 = document.getElementsByName('frontier_pair1')
      frontier_pairs2 = document.getElementsByName('frontier_pair2')
      let pair1 = ''
      let pair2 = ''
      for(let i = 0; i < frontier_pairs1.length; i++){
        if(frontier_pairs1[i].checked){
          pair1 = frontier_pairs1[i].value
        }
        if(frontier_pairs2[i].checked){
          pair2 = frontier_pairs2[i].value
        }
      }
      // console.log(pair1)
      // console.log(pair2)
      return [pair1, pair2]
    }

    function display_table_row(){
      let [pair1, pair2] = get_checked_pairs()
      let pattern1 = `${pair1}-${pair2}`
      let pattern2 = `${pair2}-${pair1}`
      let pattern  = ''
      if(json_frontier[pattern1] != null){
        pattern = pattern1
      }
      if(json_frontier[pattern2] != null){
        pattern = pattern2
      }

      console.log(pattern)

      // all .row_frontier added 'invisible'
      let row_all = document.getElementsByClassName('row_frontier')
      for(let i = 0; i < row_all.length; i++){
        if(!row_all[i].classList.contains('invisible')){
          row_all[i].classList.add('invisible')
        }
      }

      // display checked row by remove 'visible'
      if(pattern != ''){
        let row_checked = document.getElementsByClassName(pattern)
        for(let i = 0; i < row_checked.length; i++){
          row_checked[i].classList.remove('invisible')
        }
      }
    }

  </script>
</body>
</html>
