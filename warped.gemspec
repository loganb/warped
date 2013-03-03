# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'warped/version'

Gem::Specification.new do |gem|
  gem.name          = "warped"
  gem.version       = Warped::VERSION
  gem.authors       = ["Logan Bowers"]
  gem.email         = ["logan@datacurrent.com"]
  gem.description   = %q{Asynchronous I/O for Ruby using a variety of strategies (polling, threading, etc)}
  gem.summary       = %q{You'd have to be warped to use this I/O library!}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.extensions = ["ext/warped/extconf.rb"]
  
  gem.add_development_dependency "rake-compiler"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
end
