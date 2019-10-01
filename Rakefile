require 'rake/clean'
require 'date'

task default: :make_html

directory 'data'

# fx.rb based data files
file_list = 'list_fx.json'
file_one  = 'data/CoreRanger_AJ_201909_detail.json' # one of data/*json file
file_fx   = 'fx_result.csv'

# clean
CLEAN.include(file_list)
CLEAN.include("data/*.json")
CLEAN.include(file_fx)

CLOBBER.include('index.html')

task make_html: 'index.html'

def mv_src_with_date(src)
  if File.exist?(src)
    s = File::Stat.new(src)
    mtime_date = s.mtime.strftime('%Y%m%d')
    basename = File.basename(src, '.*')
    extname  = File.extname(src)
    dest = "#{src}_#{mtime_data}#{extname}"
    mv src, dest
  end
end

desc 'make index.html'
file 'index.html' => ['make_html.rb', 'fx.rb', file_fx] do
  sh 'ruby make_html.rb'
end

file 'fx.rb' => [file_list, file_one, file_fx]
file file_list do
  sh 'ruby get_list.rb'
end

file file_one do
  sh 'ruby get_data.rb'
end

file file_fx do
  sh 'ruby click365.rb'
end

desc "get today's list_fx.json"
task :get_list do
  mv_src_with_date(file_list)
  sh 'ruby get_list.rb'
end

desc "get today's data/*.json"
task :get_data => [:get_list] do
  s = File::Stat.new(file_one)
  mtime_date = s.mtime.strftime('%Y%m%d')
  sh "tar zcvf data_#{mtime_date}.tar.gz data"
  sh 'rm data/*.json'
  sh 'ruby get_data.rb'
end

desc "get today's fx_result.csv"
task :get_fx do
  mv_src_with_date('fx_result.csv')
  sh 'ruby click365.rb'
end
