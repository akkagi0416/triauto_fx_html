require 'open-uri'

now = Time.now.to_i * 1000
url_fx  = "https://attach.triautoetf.invast.jp/ranking/adviser/compositeList.json?limit=100&contribute=1&trade=2&{}&_=#{now}"

today = Date.today.strftime("%Y%m%d")

open("list_fx_#{today}.json", "w"){|f|  f.write open(url_fx).read }
