# Infoblox Host WAPI
#

require 'chef/knife'
require 'chef/knife/infoblox_base'
require 'ipaddr'

# Knife class for interacting with infoblox host records
class InfobloxHost < Chef::Knife::InfobloxBase
  banner 'knife infoblox host
[create HOSTNAME1 [HOSTNAME2...][-N NETWORK][-s START][-i IPADDR][-m MACADDR]]
[edit HOSTNAME [--{en,dis}able-dhcp][-m MACADDR][-s IP]]
[delete HOSTNAME -i IP]'
  category 'infoblox'

  common_options

  option :network,
         short: '-N NETWORK',
         long: '--network NETWORK',
         description: 'Network under which to add the host record'

  option :start,
         short: '-s IP',
         long: '--start IP',
         description: 'lowest IP from the specified network to allocate'

  option :ipaddress,
         short: '-i IP',
         long: '--ipaddress IP',
         description: 'suggest a starting IP. e.g. If you expect hostname1 to have 10.10.10.120 allocated'

  option :macaddr,
         short: '-m MACADDR',
         long: '--macaddr MACADDR',
         description: 'if a MAC address is available, enable DHCP for the IP address'

  def run
    unless valid_args?(name_args.first.downcase)
      show_usage
      ui.fatal 'Invalid Arguments specified'
      fail SystemExit
    end

    @res = infoblox_connection
    command = name_args.shift.downcase
    name_args.each { |h| create_host(h) } if command == 'create'
    edit_host(name_args.first, config[:macaddr], config[:ipaddress]) if command == 'edit'
    delete_host(name_args.first, config[:ipaddress]) if command == 'delete'
  end

  def valid_args?(command)
    if !(/(create|edit|delete)/ =~ command) # Must specify a command
      return false
    elsif !config[:network] && command == 'create' # Must specify network
      return false
    elsif !config[:ipaddress] && command == 'delete' # Must specify IP address for host to delete
      return false
    end
    true
  end

  # Takes a network in CIDR notation, pages out to infoblox and
  # returns the next available IP from it. The "ipaddress" option is meant to be the next-lowest
  # available IP in the network. We default to network address + 10
  def next_ip
    puts "Finding next IP in #{config[:network]}"
    ::Infoblox::Network.find(@res, 'network~' => config[:network]).each do |net|
      ip_network = IPAddr.new(net.remote_attribute_hash[:network]).to_range.first
      ip = net.next_available_ip(1, exclude_range(ip_network.to_i)).first
      puts "Found #{ip}"
      return ip
    end
  end

  def exclude_range(network_int)
    if config[:ipaddress]
      exclude = IPAddr.new(config[:ipaddress]).to_i - network_int
    else
      exclude = 10
    end
    network_int.upto(network_int + exclude.to_i).map { |ip| IPAddr.new(ip, Socket::AF_INET).to_s }
  end

  # Takes a hostname and network(CIDR notation), and creates the record in infoblox.
  def create_host(hostname)
    ip = next_ip
    host = ::Infoblox::Host.new(connection: @res)
    host.name = hostname
    if config[:macaddr]
      host.ipv4addrs = [ipv4addr: ip, mac: config[:macaddr]]
    else
      host.ipv4addrs = [ipv4addr: ip]
    end
    host.configure_for_dns = true
    puts "Created #{hostname} with address #{ip}" if host.post
  end

  # This is REALLY DANGEROUS. We assume that the host only has one IP address, and just overwrite it...
  def edit_host(hostname, macaddr, ipaddr)
    host = ::Infoblox::Host.find(@res, 'name~' => hostname).first
    puts "updating host #{hostname} - Old Record: #{host.remote_attribute_hash}"
    if host.ipv4addrs[0].ipv4addr == ipaddr
      host.ipv4addrs[0].mac = macaddr
      host.ipv4addrs[0].configure_for_dhcp = true
    else
      host.ipv4addrs[0].ipv4addr = ipaddr
      host.ipv4addrs[0].mac = macaddr
    end
    host.put
  end

  def delete_host(hostname, ipaddr)
    host = ::Infoblox::Host.find(@res, 'name~' => hostname, 'ipv4addr' => ipaddr).first
    puts "Deleting host record for #{hostname} - Old Record: #{host.remote_attribute_hash}"
    host.delete
  end
end
