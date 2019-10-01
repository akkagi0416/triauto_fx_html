require 'json'

# file = 'list_fx_20190924.json'
file = 'list_fx.json'

def get_default_amount(file)
  json = JSON.parse(open(file).read)

  default_amount = json[0]['DEFAULT_AMOUNT']
end

json = JSON.parse(open(file).read)

printf "  pair    roi     dd   rr margin name\n"
json.each do |row|
  name               = row['COMPOSITE_NAME']
  pair               = row['COMPOSITE_IMAGE'].sub(/\.png/, '')
  ranking_id_prefix  = row['RANKING_ID_PREFIX']
  roi                = row['ROI']
  margin_recommended = row['MARGIN_RECOMMENDED']
  margin_required    = row['MARGIN_REQUIRED']
  risk_return        = row['RISK_RETURN']

  dd = (margin_recommended.to_f - margin_required) * 2 / margin_recommended * 100
  default_amount = get_default_amount("data/#{ranking_id_prefix}_profit.json")

  printf "%s %6.1f %6.1f %4.2f %d %s\n", pair, roi, dd, risk_return, margin_recommended, name
end
