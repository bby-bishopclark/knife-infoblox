# Infoblox common
#

require 'chef/knife'
require 'infoblox'

# Rubocop wants a comment here
class Chef
  class Knife
    # Parent class for knife infoblox commands
    class InfobloxBase < Knife
      deps do
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
        require 'ipaddr'
      end

      def self.common_options
        option :infoblox_username,
               short: '-u USERNAME',
               long: '--username USERNAME',
               description: 'User name',
               proc: proc { |user| Chef::Config[:knife][:infoblox_username] = user }

        option :infoblox_password,
               short: '-p PASSWORD',
               long: '--password PASSWORD',
               description: 'Password',
               proc: proc { |pass| Chef::Config[:knife][:infoblox_password] = pass }

        option :infoblox_hostname,
               short: '-h HOSTNAME',
               long: '--hostname HOSTNAME',
               description: 'fqdn of machine hosting the infoblox api <atl1grid01.internal.secureworks.net>',
               default: 'atl1grid01.internal.secureworks.net',
               proc: proc { |hostname| Chef::Config[:knife][:infoblox_hostname] = hostname }
      end

      def password
        @password ||= ui.ask('Enter your password: ') { |q| q.echo = false }
      end

      def get_config(key)
        key = key.to_sym
        val = config[key] || Chef::Config[:knife][key]
        val
      end

      def conn_options
        config[:infoblox_password] = password unless config[:infoblox_password]
        {
          username: get_config(:infoblox_username),
          password: get_config(:infoblox_password),
          host: get_config(:infoblox_hostname)
        }
      end

      def infoblox_connection
        ::Infoblox::Connection.new conn_options
      end
    end
  end
end
