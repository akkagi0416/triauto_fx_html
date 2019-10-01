require 'erb'
require 'net/http'
require 'uri'
require 'cgi'

erb = ERB.new(DATA.read)

2018.upto(2019) do |year|
  puts "get #{year} data from click365"

  lines = erb.result(binding)

  # make POST body
  # body = '_method=POST&data%5BHistoricalData%5D%5Bsubmit_type%5D=csv&data%5BHistoricalData%5D%5Bperiod_start_type%5D=date&data%5BHistoricalData%5D%5Bperiod_start%5D%5Byear%5D=2019&data%5BHistoricalData%5D%5Bperiod_start%5D%5Bmonth%5D=1&data%5BHistoricalData%5D%5Bperiod_start%5D%5Bday%5D=1&data%5BHistoricalData%5D%5Bperiod_end_type%5D=date&data%5BHistoricalData%5D%5Bperiod_end%5D%5Byear%5D=2019&data%5BHistoricalData%5D%5Bperiod_end%5D%5Bmonth%5D=1&data%5BHistoricalData%5D%5Bperiod_end%5D%5Bday%5D=31&data%5BHistoricalData%5D%5Bproduct_type1%5D=&data%5BHistoricalData%5D%5Bproduct_type1%5D%5B%5D=USD%2FJPY&data%5BHistoricalData%5D%5Bproduct_type1%5D%5B%5D=EUR%2FJPY&data%5BHistoricalData%5D%5Bproduct_type1%5D%5B%5D=GBP%2FJPY&data%5BHistoricalData%5D%5Bproduct_type1%5D%5B%5D=AUD%2FJPY&data%5BHistoricalData%5D%5Bproduct_type1%5D%5B%5D=CHF%2FJPY&data%5BHistoricalData%5D%5Bproduct_type1%5D%5B%5D=CAD%2FJPY&data%5BHistoricalData%5D%5Bproduct_type1%5D%5B%5D=NZD%2FJPY&data%5BHistoricalData%5D%5Bproduct_type1%5D%5B%5D=ZAR%2FJPY&data%5BHistoricalData%5D%5Bproduct_type1%5D%5B%5D=TRY%2FJPY&data%5BHistoricalData%5D%5Bproduct_type2%5D=&data%5BHistoricalData%5D%5Bproduct_type2%5D%5B%5D=EUR%2FUSD&data%5BHistoricalData%5D%5Bproduct_type2%5D%5B%5D=GBP%2FUSD&data%5BHistoricalData%5D%5Bproduct_type2%5D%5B%5D=AUD%2FUSD&data%5BHistoricalData%5D%5Bproduct_type2%5D%5B%5D=NZD%2FUSD&data%5BHistoricalData%5D%5Bproduct_type2%5D%5B%5D=USD%2FCHF&data%5BHistoricalData%5D%5Bproduct_type2%5D%5B%5D=EUR%2FAUD&data%5BHistoricalData%5D%5Bproduct_type2%5D%5B%5D=EUR%2FGBP&data%5BHistoricalData%5D%5Bproduct_type3%5D=&data%5BHistoricalData%5D%5Bproduct_type4%5D=&data%5BHistoricalData%5D%5Bget_preference_all%5D=&data%5BHistoricalData%5D%5Bget_preference_all%5D%5B%5D=all&data%5BHistoricalData%5D%5Bget_preference%5D=&data%5BHistoricalData%5D%5Bget_preference%5D%5B%5D=settlement_price&data%5BHistoricalData%5D%5Bget_preference%5D%5B%5D=open&data%5BHistoricalData%5D%5Bget_preference%5D%5B%5D=high&data%5BHistoricalData%5D%5Bget_preference%5D%5B%5D=low&data%5BHistoricalData%5D%5Bget_preference%5D%5B%5D=last&data%5BHistoricalData%5D%5Bget_preference%5D%5B%5D=day_settlement_price&data%5BHistoricalData%5D%5Bget_preference%5D%5B%5D=day_before_ratio&data%5BHistoricalData%5D%5Bget_preference%5D%5B%5D=swap_point&data%5BHistoricalData%5D%5Bget_preference%5D%5B%5D=trading_volume&data%5BHistoricalData%5D%5Bget_preference%5D%5B%5D=open_interest'
  body = ''
  lines.each_line do |line|
    key, value = line.gsub(/\s/, '').split(':')
    next if key.nil?
    k = CGI.escape(key)
    v = value.nil? ? '' : CGI.escape(value)
    body += "#{k}=#{v}&"
  end

  uri = URI.parse('https://www.tfx.co.jp/historical/fx/result')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  header = { 'Content-Type' => 'application/x-www-form-urlencoded' }
  req = Net::HTTP::Post.new(uri.path, initheader = header)
  req.body = body
  res = http.request(req)
  
  open("fx_result_#{year}.csv", 'w'){|f| f.write res.body }
end

csv_2018  = open('fx_result_2018.csv').readlines
csv_2019  = open('fx_result_2019.csv').readlines
csv_merge = csv_2018 + csv_2019[3 .. -1]  # remove 2019 header
puts "merge 2018 & 2019 csv"
open('fx_result.csv', 'w'){|f| f.puts csv_merge }


__END__

_method: POST
data[HistoricalData][submit_type]: csv
data[HistoricalData][period_start_type]: date
data[HistoricalData][period_start][year]: <%= year %>
data[HistoricalData][period_start][month]: 1
data[HistoricalData][period_start][day]: 1
data[HistoricalData][period_end_type]: date
data[HistoricalData][period_end][year]: <%= year %>
data[HistoricalData][period_end][month]: 12
data[HistoricalData][period_end][day]: 31
data[HistoricalData][product_type1]: 
data[HistoricalData][product_type1][]: USD/JPY
data[HistoricalData][product_type1][]: EUR/JPY
data[HistoricalData][product_type1][]: GBP/JPY
data[HistoricalData][product_type1][]: AUD/JPY
data[HistoricalData][product_type1][]: CHF/JPY
data[HistoricalData][product_type1][]: CAD/JPY
data[HistoricalData][product_type1][]: NZD/JPY
data[HistoricalData][product_type1][]: ZAR/JPY
data[HistoricalData][product_type1][]: TRY/JPY
data[HistoricalData][product_type2]: 
data[HistoricalData][product_type2][]: EUR/USD
data[HistoricalData][product_type2][]: GBP/USD
data[HistoricalData][product_type2][]: AUD/USD
data[HistoricalData][product_type2][]: NZD/USD
data[HistoricalData][product_type2][]: USD/CHF
data[HistoricalData][product_type2][]: EUR/AUD
data[HistoricalData][product_type2][]: EUR/GBP
data[HistoricalData][product_type3]: 
data[HistoricalData][product_type4]: 
data[HistoricalData][get_preference_all]: 
data[HistoricalData][get_preference_all][]: all
data[HistoricalData][get_preference]: 
data[HistoricalData][get_preference][]: settlement_price
data[HistoricalData][get_preference][]: open
data[HistoricalData][get_preference][]: high
data[HistoricalData][get_preference][]: low
data[HistoricalData][get_preference][]: last
data[HistoricalData][get_preference][]: day_settlement_price
data[HistoricalData][get_preference][]: day_before_ratio
data[HistoricalData][get_preference][]: swap_point
data[HistoricalData][get_preference][]: trading_volume
data[HistoricalData][get_preference][]: open_interest
