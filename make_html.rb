require 'erb'
require './fx.rb'

fx = FX.new
fx.set
eurgbp = fx.fxes.to_json

erb = ERB.new(DATA.read)
# puts erb.result
open('aiu.html', 'w'){|f| f.puts erb.result }

__END__

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title></title>
</head>
<body>
  <section>
    <canvas id="myChart"></canvas>
    <form id="select1">
      <input type="radio" name="select1" value="1">1
      <input type="radio" name="select1" value="2">2
      <input type="radio" name="select1" value="3">3
    </form>
    <form id="select2">
      <input type="radio" name="select2" value="1">1
      <input type="radio" name="select2" value="2">2
      <input type="radio" name="select2" value="3">3
    </form>
  </section>
  <section>
    <table>
      <tr>
        <th>pair</th>
        <th>name</th>
        <th>roi</th>
        <th>dd</th>
        <th>推奨証拠金</th>
        <th>リスクリターン</th>
      </tr>
      <% fx.fxes.each do |pair, value| %>
        <tr>
          <td><%= pair %></td>
          <td><%= fx.fxes[pair]['name'] %></td>
          <td><%= fx.fxes[pair]['roi'].round(1) %></td>
          <td><%= fx.fxes[pair]['dd'].round(1) %></td>
          <td><%= fx.fxes[pair]['margin_recommended'].round(0) %></td>
          <td><%= fx.fxes[pair]['risk_return'].round(2) %></td>
        </tr>
      <% end %>
    </table>
  </section>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.24.0/moment.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
  <script>
    aaa = <%= eurgbp %>
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
            data: data[0],
            borderColor: 'blue',
            yAxisID: 'y-axis-1',
          },
          {
            data: data[1],
            borderColor: 'red',
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
              unit: 'day'
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
    document.getElementById('select1').addEventListener('click', function(){
      var element = document.getElementById("select1")
      var select1 = element.select1
      var select1_value = select1.value
      chart.config.data.datasets[0].data = data[select1_value - 1]
      chart.update()
    })
    document.getElementById('select2').addEventListener('click', function(){
      var element = document.getElementById("select2")
      var select2 = element.select2
      var select2_value = select2.value
      chart.config.data.datasets[1].data = data[select2_value - 1]
      chart.update()
    })

  </script>
</body>
</html>
