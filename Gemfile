source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "= #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['>= 3.0']
end

gem 'rake', '10.1.1'
gem 'puppet-lint'
gem 'rspec-puppet'
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper'
