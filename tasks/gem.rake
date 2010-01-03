begin
  require 'jeweler'
  
  Jeweler::Tasks.new do |gem|
    gem.name = "piglet"
    gem.summary = %Q{Piglet is a DSL for Pig scripts}
    gem.description = %Q{Piglet aims to look like Pig Latin while allowing for things like loops and control of flow that are missing from Pig.}
    gem.email = "theo@iconara.net"
    gem.homepage = "http://github.com/iconara/piglet"
    gem.authors = ["Theo Hultberg"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.version = Piglet::VERSION
    gem.test_files = FileList['spec/**/*.rb']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
end