task default: :make_html

desc ''
task make_html: 'index.html'

desc 'make index.html'
file 'index.html' => ['make_html.rb', 'fx.rb'] do
  sh 'ruby make_html.rb'
end
