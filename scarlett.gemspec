# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scarlett/version'

Gem::Specification.new do |gem|
  gem.name          = "scarlett"
  gem.version       = Scarlett::VERSION
  gem.authors       = ["Guillermo Iguaran", "Roberto Miranda"]
  gem.email         = ["guilleiguaran@gmail.com", "rjmaltamar@gmail.com"]
  gem.description   = %q{Simple background jobs}
  gem.summary       = %q{Simple background jobs using Rubinius Actors and RabbitMQ}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rubinius-actor"
  gem.add_dependency "case"
  gem.add_dependency "bunny", "~> 0.9.0.pre9"

  gem.add_development_dependency "rake"
end
