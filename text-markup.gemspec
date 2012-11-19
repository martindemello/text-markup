# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'text/markup/version'

Gem::Specification.new do |gem|
  gem.name          = "text-markup"
  gem.version       = Text::Markup::VERSION
  gem.authors       = ["Martin DeMello"]
  gem.email         = ["martindemello@gmail.com"]
  gem.description   = %q{Library for handling marked-up text}
  gem.summary       = %q{Library for handling marked-up text}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
