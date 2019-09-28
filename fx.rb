require 'json'
require 'yaml'

#
# fxes
#
#   pair                'EURGBP'
#   name                'コアレンジャー_ユーロ/英ポンド'
#   ranking_id_prefix   'CoreRanger_EG_201909'
#   margin_recommended  258295.5
#   margin_required     182400
#   risk_return         2.6968792616163015
#   roi                 158.49
#   dd                  
#   profit              {'2018-01-02' => -105, '2018-01-03' => -173 ...}
#   ohlc                {'2018-01-02' => [o, h, l, c], '2018-01-03' => [o, h, l, c]}
#

class FX
  attr_reader :fxes

  def initialize
    @fxes = nil
  end

  def set
    @fxes = set_list_data('list_fx_20190927.json')
    set_profit
    set_ohlc
    calc_AUDNZD
  end

  def dump_yaml(file)
    open(file, 'w'){|f| f.write(YAML.dump(fxes)) }
  end

  def load_yaml(file)
    @fxes = YAML.load(open(file).read)
  end

  def output_profits(file)
    open(file, 'w') do |f|
      @fxes.keys.each do |pair|
        @fxes[pair]['profit'].each do |date, profit|
          f.puts "#{date},#{pair},#{profit}"
        end
      end
    end
  end

  private

    def set_list_data(file)
      fxes = {}
      json = JSON.parse(open(file).read)
      json.each do |row|
        pair               = row['COMPOSITE_IMAGE'].sub(/\.png/, '')
        name               = row['COMPOSITE_NAME']
        ranking_id_prefix  = row['RANKING_ID_PREFIX']
        margin_recommended = row['MARGIN_RECOMMENDED']
        margin_required    = row['MARGIN_REQUIRED']
        risk_return        = row['RISK_RETURN']
        roi                = row['ROI']

        dd = (margin_recommended.to_f - margin_required) * 2 / margin_recommended * 100

        fxes[pair] = {
          'name'               => name,
          'margin_recommended' => margin_recommended,
          'ranking_id_prefix'  => ranking_id_prefix,
          'risk_return'        => risk_return,
          'roi'                => roi,
          'dd'                 => dd,
          'profit'             => {},
          'ohlc'               => {}
        }
      end

      fxes
    end

    def set_profit
      @fxes.each do |k, v|
        file_profit = v['ranking_id_prefix']  
        profit = get_profit("data/#{file_profit}_profit.json")
        @fxes[k]['profit'] = profit
      end
    end

    def get_profit(file)
      json = JSON.parse(open(file).read)
      
      pair = json[0]['ETF_NAME_JA']
      margin_recommended = @fxes[pair]['margin_recommended']

      profits = {}
      sum = 0
      json[0]['DAILY_STATS'].each do |daily|
        date             = daily['DAY']
        profit           = daily['PROFIT']
        valuation_profit = daily['VALUATION_PROFIT']

        sum += profit
        # profits[date] = sum + valuation_profit
        profit_loss = (sum.to_f + valuation_profit) / margin_recommended * 100
        profits[date] = profit_loss.round(2)
      end

      profits
    end
    
    def set_ohlc
      file_ohlc = 'fx_result.csv'
      open(file_ohlc).each_with_index do |line, i|
        next if i <= 2

        pair = line.split(',')[0].sub(%r{/}, '')
        date = line.split(',')[2]
        o    = line.split(',')[4].to_f
        h    = line.split(',')[5].to_f
        l    = line.split(',')[6].to_f
        c    = line.split(',')[7].to_f

        @fxes[pair]['ohlc'][date] = [o, h, l, c]
      end
    end

    def calc_AUDNZD
      @fxes['AUDJPY']['ohlc'].each do |k, v|
        date = k
        aud  = v 
        nzd  = fxes['NZDJPY']['ohlc'][date]

        o = aud[0] - nzd[0]
        h = aud[1] - nzd[1]
        l = aud[2] - nzd[2]
        c = aud[3] - nzd[3]

        @fxes['AUDNZD']['ohlc'][date] = [o, h, l, c]
      end
    end
  # end private
end



# #
# # set list data
# #
# file_list = 'list_fx_20190924.json'
# fxes = set_list_data(file_list)
#
# #
# # set profit
# #
# fxes.each do |k, v|
#   file_history = v['ranking_id_prefix']  
#   history = set_history("data/#{file_history}_history.json")
#   fxes[k]['history'] = history
# end
#
# #
# # set ohlc
# #
# file_ohlc = 'fx_result.csv'
# open(file_ohlc).each_with_index do |line, i|
#   next if i <= 2
#
#   pair = line.split(',')[0].sub(%r{/}, '')
#   date = line.split(',')[2]
#   o    = line.split(',')[4].to_f
#   h    = line.split(',')[5].to_f
#   l    = line.split(',')[6].to_f
#   c    = line.split(',')[7].to_f
#
#   fxes[pair]['ohlc'][date] = [o, h, l, c]
# end

#
# calc AUDNZD ohlc
#
# fxes['AUDJPY']['ohlc'].each do |k, v|
#   date = k
#   aud  = v 
#   nzd  = fxes['NZDJPY']['ohlc'][date]
#
#   o = aud[0] - nzd[0]
#   h = aud[1] - nzd[1]
#   l = aud[2] - nzd[2]
#   c = aud[3] - nzd[3]
#
#   fxes['AUDNZD']['ohlc'][date] = [o, h, l, c]
# end

# open('triauto.yml', 'w'){|f| f.write(YAML.dump(fxes)) }

if __FILE__ == $0
  fx = FX.new
  # fx.dump_yaml('triauto.yml')
  # fx.load_yaml('triauto.yml')
  fx.set

  # pp fx.fxes
end
