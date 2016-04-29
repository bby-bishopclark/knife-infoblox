# read config file and build infoblox base class
#
require 'chef/knife'
require 'chef/knife/infoblox_base'

# Class to interact with infoblox network objects
class InfobloxNetwork < Chef::Knife::InfobloxBase
  banner 'knife infoblox network [NETWORK | [ --ip-address|-i IP_ADDRESS ] | [ --attr|-a \'ATTRIB=VAL\' ] [ --retrieve|-r EXTENDED_ATTR ] [ --next-available|-n [--exclude|-N LIST ] [--count|-c COUNT]]]'
  category 'infoblox'

  common_options

  option :exclude,
         short: '-N EXCLUDE',
         long: '--exclude EXCLUDE',
         description: 'comma-delimited list of IPs to exclude',
         default: [],
         proc: proc { |exclude| exclude.to_s.split(',') }

  option :next_available,
         short: '-n',
         long: '--next-available',
         description: 'return next available IP (default 1, if #COUNT is supplied return next #COUNT available IPs)',
         boolean: false

  option :attr,
         short: '-a ATTRIB=VAL',
         long: '--attr ATTRIB=VAL',
         description: 'return the subnet in CIDR notation of the requested network where :extensible_attributes[ATTRIB] = VAL',
         default: nil

  option :ip_addr,
         short: '-i IP_ADDRESS',
         long: '--ip-address IP_ADDRESS',
         description: 'return the VLAN ID and subnet for a given IP address',
         default: nil

  option :count,
         short: '-c COUNT',
         long: '--count COUNT',
         description: 'the number of available IPs to return for a given network',
         default: nil

  option :retrieve,
         short: '-r EXTENDED_ATTR',
         long: '--retrieve EXTENDED_ATTR',
         description: 'a comma-delimited list of extensible attributes to return',
         default: nil

  def run
    @res = infoblox_connection

    search_by_attr if config[:attr]
    search_by_ip if config[:ip_addr]
    show_all_networks if name_args.size == 0 && (config[:ip_addr].nil? && config[:attr].nil?)
    get_next_available(config[:exclude], config[:count]) if config[:count] && config[:next_available] && name_args.size > 0
    search_by_subnet if name_args.size > 0 && config[:next_available].nil?
  end

  def search_by_attr
    ::Infoblox::Network.all(@res).each do |net|
      ext_attrs = net.remote_attribute_hash[:extensible_attributes]
      if ext_attrs[config[:attr].split('=')[0]].respond_to?(:split)
        if ext_attrs[config[:attr].split('=')[0]] == config[:attr].split('=')[1]
          ret = "#{net.remote_attribute_hash[:network]}"
          if config[:retrieve]
            begin
              config[:retrieve].split(',').map do |i|
                ret << " #{ext_attrs[i]}"
              end
            rescue
              puts "unable to locate key in extensible attributes - #{config[:retrieve]}"
            end
          end
        end
      end
    end
  end

  def search_by_ip
    ip_int = IPAddr.new(config[:ip_addr], Socket::AF_INET).to_i
    ::Infoblox::Network.all(@res).each do |net|
      # network address = network.first.to_i
      # broadcast address = network.last.to_i
      network = IPAddr.new(net.remote_attribute_hash[:network], Socket::AF_INET).to_range
      if network.first.to_i <= ip_int && ip_int <= network.last.to_i
        puts "Subnet:#{net.remote_attribute_hash[:network]} VLAN:#{net.remote_attribute_hash[:extensible_attributes]['VLAN ID']}"
      end
    end
  end

  def show_all_networks
    ::Infoblox::Network.all(@res).each { |net| puts "#{net.remote_attribute_hash.inspect}" }
  end

  def search_by_subnet 
    subnet = name_args.shift 
    ::Infoblox::Network.find(@res, 'network~' => subnet).each do |net| 
      if net.remote_attribute_hash[:network] =~ /#{subnet}/ 
        ret = "#{net.remote_attribute_hash[:network]}" 
        ext_attrs = net.remote_attribute_hash[:extensible_attributes] 
        if config[:retrieve] 
          config[:retrieve].split(',').map do |i| 
            ret << " #{ext_attrs[i]}" 
          end 
        end 
        puts ret 
      end 
    end 
  end

  def get_next_available(exclude, count)
    search = ::Infoblox::Network.find(@res, 'network~' => name_args.shift)
    if config[:next_available] && exclude && count
      puts "#{search.pop.next_available_ip(count, exclude)}"
    elsif config[:next_available] && count
      puts "#{search.pop.next_available_ip(count)}"
    elsif config[:next_available]
      puts "#{search.pop.next_available_ip}"
    end
  end
end
