# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "smart_devnet"
  gem.version       = "0.0.7"
  gem.authors       = ["Katherine G. Pe", "Bryan Bibat"]
  gem.email         = ["info@bridgeutopiaweb.com"]
  gem.description   = %q{Lightweight gem for the SMART Devnet API}
  gem.summary       = %q{Currently supports SMS API only}
  gem.homepage      = "http://www.smart.com.ph/developer"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'minitest'
  gem.add_runtime_dependency 'httparty', '~> 0.9.0'
end
