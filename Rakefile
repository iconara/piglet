require 'rubygems'
require 'rake'
require 'lib/piglet'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "Piglet"
    gem.summary = %Q{Piglet is a DSL for Pig scripts}
    gem.description = %Q{Piglet aims to look like Pig Latin while allowing for things like loops and control of flow that are missing from Pig.}
    gem.email = "theo@iconara.net"
    gem.homepage = "http://github.com/iconara/piglet"
    gem.authors = ["Theo Hultberg"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.version = Piglet::VERSION
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "piglet #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options << '--charset' << 'utf-8'
end
