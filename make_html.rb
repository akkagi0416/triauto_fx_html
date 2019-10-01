require 'erb'
require './fx.rb'
require '../../calc_rule/myarray.rb'

fx = FX.new
fx.set
json_fx = fx.fxes.to_json

pairs = fx.fxes.keys

def calc_correlation(fx, pair1, pair2)
  arr1 = fx.fxes[pair1]['profit'].map{|date, profit| profit }
  arr2 = fx.fxes[pair2]['profit'].map{|date, profit| profit }
  r(arr1, arr2).round(2)
end

erb = ERB.new(DATA.read)
# puts erb.result
open('index.html', 'w'){|f| f.write erb.result }

__END__

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title></title>
  <style>
    body{
      color: #333;
    }
    main{
      width: 80%;
      max-width: 960px;
      margin: 0 auto;
    }
    section{
      margin-bottom: 5rem;
    }
    #chart form{
      font-size: 0.8rem;
    }
    #summary td, #summary th{
      font-size: 0.8rem;
      text-align: right;
    }
    #summary td:nth-of-type(2),
    #summary th:nth-of-type(2){
      padding-left: 1rem;
      text-align: left;
    }
    #correlation td, #correlation th{
      font-size: 0.8rem;
      text-align: center;
    }
  </style>
</head>
<body>
  <main>
    <section id="chart">
      <h2>損益 or チャート比較</h2>
      <canvas id="myChart"></canvas>
      <h3>左軸</h3>
      <form id="pair_type1">
        <input type="radio" name="pair_type1" value="profit" checked>損益
        <input type="radio" name="pair_type1" value="ohlc">チャート
      </form>
      <form id="pair1">
        <% fx.fxes.each.with_index do |(pair, value), i| %>
          <input type="radio" name="pair1" value="<%= pair %>" <%= i == 0 ? 'checked' : '' %>><%= pair %>
        <% end %>
      </form>
      <h3>右軸</h3>
      <form id="pair_type2">
        <input type="radio" name="pair_type2" value="profit" checked>損益
        <input type="radio" name="pair_type2" value="ohlc">チャート
      </form>
      <form id="pair2">
        <% fx.fxes.each.with_index do |(pair, value), i| %>
          <input type="radio" name="pair2" value="<%= pair %>" <%= i == 0 ? 'checked' : '' %>><%= pair %>
        <% end %>
      </form>
    </section><!-- //chart -->

    <section id="summary">
      <h2>指標一覧</h2>
      <table>
        <tr>
          <th>通貨ペア</th>
          <th>名前</th>
          <th>ROI(%)</th>
          <th>推奨証拠金(円)</th>
          <th>リスクリターン</th>
          <th>年利(%)</th>
          <th>標準偏差(%)</th>
          <th>シャープレシオ</th>
          <th>DD(%)</th>
        </tr>
        <% fx.fxes.each do |pair, value| %>
          <tr>
            <td><%= pair %></td>
            <td><%= fx.fxes[pair]['name'] %></td>
            <td><%= sprintf "%.1f", fx.fxes[pair]['roi'] %></td>
            <td><%= sprintf "%d", fx.fxes[pair]['margin_recommended'] %></td>
            <td><%= sprintf "%.2f", fx.fxes[pair]['risk_return'] %></td>
            <%
              profits = fx.fxes[pair]['profit'].sort{|(date1, p1), (date2, p2)| date1 <=> date2 }
              nenri   = fx.fxes[pair]['roi'] / profits.count * 365
              delta = []
              profits.each_with_index do |(date, profit), i|
                break if i == profits.count - 1
                profit_now  = profits[i][1]
                profit_next = profits[i+1][1]
                delta << profit_next - profit_now
              end
              sd      = delta.sd * Math.sqrt(365)
              sharp   = nenri / sd
            %>
            <!--
            <td><%= sprintf "%.1f", nenri %></td>
            <td><%= sprintf "%.1f", sd %></td>
            -->
            <td><%= sprintf "%.1f", fx.fxes[pair]['nenri'] %></td>
            <td><%= sprintf "%.1f", fx.fxes[pair]['sd'] %></td>
            <td><%= sprintf "%.2f", sharp %></td>
            <td><%= sprintf "%.1f", fx.fxes[pair]['dd'] %></td>
          </tr>
        <% end %>
      </table>
      <div>
        <p>リスクリターンに応じて区分しているようです</p>
        <ul>
          <li>～1 Bad</li>
          <li>1～ Good</li>
          <li>2～ Very Good</li>
          <li>3～ Excellent</li>
        </ul>
      </div>
    </section><!-- //summary -->

    <section id="correlation">
      <h2>相関係数</h2>
      <table>
        <tr>
          <th>-</th>
          <% pairs.each do |pair| %>
            <th><%= pair %></th>
          <% end %>
        </tr>
        <% pairs.each do |pair1| %>
          <tr>
            <th><%= pair1 %></th>
            <% pairs.each do |pair2| %>
            <%
              cor = calc_correlation(fx, pair1, pair2)
              if cor > 0
                # rgba = "rgba(0, 0, 255, #{cor})"
                rgba = "rgba(128, 128, 255, #{cor})"
              else
                # rgba = "rgba(255, 0, 0, #{cor})"
                rgba = "rgba(255, 128, 128, #{cor})"
              end
            %>
            <td style="background-color: <%= rgba %>"><%= cor %></td>
            <% end %>
          </tr>
        <% end %>
      </table>
    </section><!-- //correlation -->
  </main>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.24.0/moment.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
  <script>
    var json_fx = <%= json_fx %>
  </script>
  <script>
    data = [
      [
        {t: '2019-01-01', y: 3},
        {t: '2019-01-02', y: 5},
        {t: '2019-01-03', y: 2},
      ],
      [
        {t: '2019-01-01', y: 8},
        {t: '2019-01-02', y: 3},
        {t: '2019-01-03', y: 4},
      ],
      [
        {t: '2019-01-01', y: 1},
        {t: '2019-01-02', y: 0},
        {t: '2019-01-03', y: 7},
      ],
    ]
    /*
    data1 = [
      {t: '2019-01-01', y: 3},
      {t: '2019-01-02', y: 5},
      {t: '2019-01-03', y: 2},
    ]
    data2 = [
      {t: '2019-01-01', y: 8},
      {t: '2019-01-02', y: 3},
      {t: '2019-01-03', y: 4},
    ]
    data3 = [
      {t: '2019-01-01', y: 1},
      {t: '2019-01-02', y: 0},
      {t: '2019-01-03', y: 7},
    ]
    */
  </script>
  <script>
    var ctx = document.getElementById('myChart').getContext('2d');
    var cfg = {
      type: 'line',
      data: {
        datasets: [
          {
            // data: data[0],
            data: null,
            // borderColor: 'rgba(128, 128, 255, 1)',
            borderColor: 'blue',
            fill: false,
            borderWidth: 2,
            pointRadius: 0,
            yAxisID: 'y-axis-1',
          },
          {
            //data: data[1],
            data: null,
            // borderColor: 'rgba(255, 128, 128, 1)',
            borderColor: 'red',
            fill: false,
            borderWidth: 2,
            pointRadius: 0,
            yAxisID: 'y-axis-2',
          },
        ]
      },
      options: {
        responsive: true,
        scales:     {
          xAxes: [{
            type:       "time",
            time:       {
              parser: 'YYYY-MM-DD',
              displayFormats: {
                'month': 'MM/YYYY'
              },
              unit: 'month'
            },
          }],
          yAxes: [{
            type: 'linear',
            position: 'left',
            id: 'y-axis-1',
          },{
            type: 'linear',
            position: 'right',
            id: 'y-axis-2',
          }]
        }
      }
    }
    var chart = new Chart(ctx, cfg)
    update_chart('pair1')
    update_chart('pair2')

    function make_data(pair, pair_type){
      var arr
      if(pair_type == 'profit'){
          arr = make_data_profit(pair)
      }
      if(pair_type == 'ohlc'){
          arr = make_data_chart(pair)
      }
      return arr
    }

    function make_data_profit(pair){
      var profits = json_fx[pair]['profit']
      var arr = []
      for(k in profits){
          arr.push({t: k, y: profits[k]})
      }
      return arr
    }

    function make_data_chart(pair){
      var ohlcs = json_fx[pair]['ohlc']
      var arr = []
      // collect close data of ohlc
      for(k in ohlcs){
          arr.push({t: k, y: ohlcs[k][3]})  // ohlc[k] = [o, h, l, c]
      }
      return arr
    }

    function update_chart(value){
      let number = value.slice(-1)  // get value number  ex) 'pair1' -> '1'
      let pairs      = document.getElementsByName("pair" + number)
      let pair_types = document.getElementsByName("pair_type" + number)
      let pair = '';
      let pair_type = ''
      for(let i = 0; i < pairs.length; i++){
        if(pairs[i].checked){
          pair = pairs[i].value
        }
      }
      for(let i = 0; i < pair_types.length; i++){
        if(pair_types[i].checked){
          pair_type = pair_types[i].value
        }
      }
      if( pair != '' && pair_type != ''){
        chart.config.data.datasets[number - 1].label = pair
        chart.config.data.datasets[number - 1].data  = make_data(pair, pair_type)
        if(pair_type == 'profit'){
          chart.config.options.scales.yAxes[number - 1].ticks.max = 200
          chart.config.options.scales.yAxes[number - 1].ticks.min = -50
        }else{
          delete(chart.config.options.scales.yAxes[number - 1].ticks.max)
          delete(chart.config.options.scales.yAxes[number - 1].ticks.min)
        }
        chart.update()
      }
    }

    radios = ['pair1', 'pair2', 'pair_type1', 'pair_type2']
    radios.forEach(function(radio){
      // console.log(radio)
      document.getElementById(radio).addEventListener('click', function(){
        update_chart(radio)
      })
    })
    /*
    document.getElementById('pair1').addEventListener('click', function(){
      var pair      = document.getElementById("pair1").pair1.value
      var pair_type = document.getElementById("pair_type1").pair_type1.value
      console.log(pair)
      chart.config.data.datasets[0].label = pair
      chart.config.data.datasets[0].data  = make_data(pair, pair_type)
      chart.update()
      update_chart('pair1')
    })
    document.getElementById('pair2').addEventListener('click', function(){
      var pair      = document.getElementById("pair2").pair2.value
      var pair_type = document.getElementById("pair_type2").pair_type2.value
      chart.config.data.datasets[1].label = pair
      chart.config.data.datasets[1].data  = make_data(pair, pair_type)
      chart.update()
    })
    */

  </script>
</body>
</html>
