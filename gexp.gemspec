# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gexp/version'

Gem::Specification.new do |gem|
  gem.name          = "gexp"
  gem.version       = Gexp::VERSION
  gem.authors       = ["Kazantsev Nickolay"]
  gem.email         = ["kazantsev.nickolay@gmail.com"]
  gem.description   = %q{Gexp - comand hadlers}
  gem.summary       = %q{Gexp - comand hadlers}
  gem.homepage      = "http://github.com/realb0t/gexp"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.rubyforge_project = "gexp"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rr"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "state_machine"
  gem.add_development_dependency "activesupport"
  gem.add_development_dependency 'bson', '= 1.8.0'
  gem.add_development_dependency 'bson_ext', '= 1.8.0'
  gem.add_development_dependency 'mongo', '~> 1.8.0'
  gem.add_development_dependency "mongoid", "~> 3.0.0"
  gem.add_development_dependency 'money-mongoid', '= 0.1.2'
  gem.add_development_dependency "mongoid-rspec", '= 1.4.5'
end
