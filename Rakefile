$: << File.expand_path('../lib', __FILE__)

unless defined?(Bundler)
  require 'rubygems'
  require 'bundler'
end

Bundler.setup

require 'piglet'

task :default => :spec

Dir[File.join(File.dirname(__FILE__), 'tasks', '*.rake')].each { |t| load t }