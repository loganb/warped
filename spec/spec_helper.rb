require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

RSpec.configure do |c|
  c.formatter = :documentation
  c.color_enabled = true
end

require 'warped'
