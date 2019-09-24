require 'json'
require 'httpclient'


def get_history(prefix)
  url = 'https://attach.triautoetf.invast.jp/ranking/adviser/rankingItems.json?history=true&json=true'
  h = HTTPClient.new
  params = {'id' => ["#{prefix}_18"] }
  # res = h.post(url, '{"id":["CoreRanger_EG_201909_18"]}', 'Content-Type' => 'application/json')
  res = h.post(url, params.to_json, 'Content-Type' => 'application/json')

  open("data/#{prefix}_history.json", 'w'){|f| f.write res.body }
end

def get_detail(id, prefix)
  now = Time.now.to_i * 1000
  url = "https://attach.triautoetf.invast.jp/ranking/adviser/compositeDetail.json?id=#{id}&period=18&{}&_=#{now}"

  json = open(url).read
  open("data/#{prefix}_detail.json", 'w'){|f| f.write json }
end

json = JSON.parse(open('list_fx_20190920.json').read)

json.each do |row|
  id = row['COMPOSITE_ID']
  prefix = row['RANKING_ID_PREFIX']

  puts "#{id} #{prefix}"

  get_detail(id, prefix)
  get_history(prefix)


  sleep(1)
end
