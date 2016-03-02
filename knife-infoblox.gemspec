# -*- encoding: utf-8 -*-

$:.push File.expand_path('../lib', __FILE__)
require 'knife-infoblox/version'

Gem::Specification.new do |s|
  s.name        = 'knife-infoblox'
  s.version     = Knife::Infoblox::VERSION
  s.summary     = %q{Knife support for interacting with infoblox}
  s.description = %q{I sure like infoblox!!!!}
  s.authors     = ['Zach Morgan']
  s.email       = 'zmorgan@secureworks.com'
  s.files       = [
'.gitignore',
'CHANGELOG.md',
'LICENSE',
'README.md',
'Rakefile',
'knife-infoblox.gemspec',
'lib/chef/knife/infoblox_base.rb',
'lib/chef/knife/infoblox_dns.rb',
'lib/chef/knife/infoblox_host.rb',
'lib/chef/knife/infoblox_network.rb',
'lib/knife-infoblox/version.rb',
'spec/unit/infoblox_host.rb',
'spec/unit/infoblox_network.rb',
'spec/spec_helper.rb'
  ]
  s.test_files  = s.files.grep(%r{^(test|spec|features)/})
  s.homepage    = 'https://stash.secureworks.net/'
  s.license     = 'Apache-2.0'
  s.require_paths = ['lib']
  s.add_dependency 'chef', '~> 12.3'
  s.add_dependency 'infoblox', '~> 0.2'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'rubocop', '~> 0.27'
  s.add_development_dependency 'webmock', '~> 1.20'
  s.add_development_dependency 'vcr', '~> 2.9'
  s.add_development_dependency 'guard', '~> 2.8'
  s.add_development_dependency 'guard-rspec', '~> 4.3'
  s.add_development_dependency 'rake', '~> 0'
  s.add_development_dependency 'knife-solo', '~> 0'
  s.add_development_dependency 'knife-zero', '~> 0'
  s.add_development_dependency 'coveralls', '~> 0'
  s.add_development_dependency 'countloc', '~> 0'
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'simplecov-console', '~> 0'
end
