# Infoblox DNS WAPI
#

require 'chef/knife'
require 'chef/knife/infoblox_base'

# Class to interact with DNS records in infoblox
class InfobloxDns < Chef::Knife::InfobloxBase
  banner 'knife infoblox dns [cname HOSTNAME TARGET ] | [arecord HOSTNAME IP ] | [ptr HOSTNAME TARGET -s IPADDR]'
  category 'infoblox'

  common_options

  option :infoblox_suggest,
         short: '-s IPADDR',
         long: '--suggest IPADDR',
         description: 'IP address for which to add PTR records'

  def run
    @res = infoblox_connection
    command = name_args.shift.downcase

    unless valid_args? command
      show_usage
      exit 1
    end

    create_arecord(name_args[0], name_args[1]) if command == 'arecord'
    create_cname(name_args[0], name_args[1]) if command == 'cname'
    create_ptr(name_args[0], name_args[1], config[:suggest]) if command == 'ptr'
  end

  def valid_args?(command)
    if !(/(cname|arecord|ptr)/ =~ command) # Must specify type of record
      return false
    elsif name_args.length < 2 # must specify hostname and target
      return false
    end
    true
  end

  # Takes a hostname and IP address, and creates the record in infoblox.
  # {:name=>"pvddc01.ad.secureworkslab.com", :ipv4addr=>"10.82.159.165", :ttl=>3600, :extensible_attributes=>{}, :view=>"labad"}
  def create_arecord(hostname, ipaddr)
    host = ::Infoblox::Arecord.new(connection: @res)
    host.name = hostname
    host.ipv4addr = ipaddr
    host.ttl = 3600
    host.post
  end

  # {:name=>"atldc01.ad-qalab.secureworks.net", :canonical=>"atldc01.ad.secureworkslab.com", :extensible_attributes=>{}, :view=>"labad"}
  def create_cname(hostname, target)
    host = ::Infoblox::Cname.new(connection: @res)
    host.name = hostname
    host.canonical = target
    host.post
    puts "Created CNAME #{hostname} => #{target}"
  end

  # {:ipv4addr=>"127.0.0.1", :name=>"1.0.0.127.in-addr.arpa", :ptrdname=>"localhost", :extensible_attributes=>{}, :view=>"ext-zones"}
  def create_ptr(hostname, target, ipaddr)
    host = ::Infoblox::Ptr.new(connection: @res)
    host.name = target
    host.ipv4addr = ipaddr
    host.ptrdname = hostname
    host.post
  end
end
