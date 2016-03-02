require 'spec_helper'
require 'lib/chef/knife/infoblox_network'
InfobloxNetwork.load_deps

describe InfobloxNetwork do
  let(:stdout_io) { StringIO.new }
  let(:stderr_io) { StringIO.new }
  let(:argv) { %w(create x-test.internal.tld) }

  def stdout
    stdout_io.string
  end

  subject(:knife) do
    InfobloxNetwork.new(argv).tap do |c|
      allow(c).to receive(:output).and_return(true)
      c.parse_options(argv)
      c.merge_configs
    end
  end

  describe '#run' do
    before(:each) do
      Chef::Config.reset
      expect(subject).to receive(:get_config).with(:infoblox_username).at_least(:once).and_return('test')
      expect(subject).to receive(:get_config).with(:infoblox_password).at_least(:once).and_return(password)
      expect(subject).to receive(:get_config).with(:infoblox_hostname).at_least(:once).and_return('infoblox.example.net')
      stub_request(:get, "https://test:hootytooty@infoblox.example.net/wapi/v1.0/network?_return_fields=comment,extensible_attributes,network,network_view,network_container&network~=create").
         with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Faraday v0.9.2'}).
         to_return(:status => 200, :body => "[]", :headers => {})
    end
    # This is such a cluster at this point I don't even know where to start. I should probably refactor the infoblox_network
    # command to something maintainable before trying to write meaningful tests.
    # when config[:vlan_id] is set, should search each net for matching net[:extensible_attributes]['VLAN ID']
    # when config[:ip_addr] is set, should return matching network where network_addr < ip_addr < broadcast_addr
    # when name_args.size == 0 should return all nets
    # when name_args.size > 0 and config[:next_available] is not set should return the network extensible_attributes for the specified net
    # when name_args.size > 0 and config[:next_available] is set should return the next available IP in the specified network
    # when name_args.size > 0 and config[:next_available] + config[:exclude] are set should return the next available IP in the specified network, excluding the specified EXCLUDE addresses
    # when name_args.size > 0 and config[:next_available] + config[:exclude] + config[:count] are set should return the next COUNT available IPs in the specified network, excluding the specified EXCLUDE addresses
    context 'when all else fails' do
      let(:password) { 'hootytooty' }
      let(:ui) { double('Ui', ask: password) }
      it 'still runs' do
        expect(subject).to receive(:ui).at_least(:once).and_return ui
        knife.run
      end
    end
  end
end
