require_relative '../lib/chef/knife/infoblox_dns'
require_relative '../lib/chef/knife/infoblox_host'
require_relative '../lib/chef/knife/infoblox_network'
require_relative '../lib/chef/knife/infoblox_base'

require 'webmock/rspec'
require 'json'
require 'yaml'

WebMock.disable_net_connect!(allow_localhost: true)
