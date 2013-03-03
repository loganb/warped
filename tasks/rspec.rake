require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

desc "Run tests with SimpleCov"
RSpec::Core::RakeTask.new('cov') do |t|
  ENV['COVERAGE'] = "true"
end