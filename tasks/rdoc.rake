# encoding: utf-8

require 'rake/rdoctask'
require 'sdoc'


Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "piglet #{Piglet::VERSION}"
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.options << '--charset' << 'utf-8'
end
