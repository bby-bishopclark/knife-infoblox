require 'spec_helper'
require 'lib/chef/knife/infoblox_host'
InfobloxHost.load_deps

describe InfobloxHost do
  let(:stdout_io) { StringIO.new }
  let(:stderr_io) { StringIO.new }
  let(:argv) { %w(create x-test.internal.tld) }

  def stdout
    stdout_io.string
  end

  subject(:knife) do
    InfobloxHost.new(argv).tap do |c|
      allow(c).to receive(:output).and_return(true)
      c.parse_options(argv)
      c.merge_configs
    end
  end

  describe '#run' do
    before(:each) do
      allow(knife).to receive(:create_host)
      allow(knife).to receive(:next_ip)
      Chef::Config.reset
    end
    # throws a fatal error when an invalid combination of name_args and options is specified
    context 'when invalid arguments are supplied' do
      let(:argv) { %w(every bob) }
      let(:password) { 'hootytooty' }
      let(:ui) { double('Ui', ask: password) }
      it 'exits with a fatal error' do
        expect(subject).to receive(:ui).at_least(:once).and_return ui
        expect(subject).to receive(:show_usage)
        expect(knife.ui).to receive(:fatal)
        expect { knife.run }.to raise_error(SystemExit)
      end
    end
    # calls XYZ_host when the prerequisite arguments are supplied
    context 'when valid arguments are supplied' do
      let(:password) { 'hootytooty' }
      let(:ui) { double('Ui', ask: password) }
      let(:argv) { %w(create infoblox.test.example.net -N 127.0.0.0/8) }
      it 'runs the associated command' do
        expect(subject).to receive(:get_config).with(:infoblox_username).at_least(:once).and_return('test')
        expect(subject).to receive(:get_config).with(:infoblox_password).at_least(:once).and_return(password)
        expect(subject).to receive(:get_config).with(:infoblox_hostname).at_least(:once).and_return('infoblox.example.net')
        expect(subject).to receive(:ui).and_return ui
        knife.run
      end
    end
  end

#  describe '#create_host' do
#     with a given hostname, creates an Infoblox::Host object using the IP (from #next_ip) and the mac address specified on the command line (if any)
#     should result in an Infoblox::Host.post
#  end
#  describe '#edit_host' do
#     with a given hostname, mac address and IP, will print the existing host object and update the object with the specified IP address
#     should result in an Infoblox::Host.put
#  end
#  describe '#delete_host' do
#     with a given hostname and IP will print the existing host object and delete it from the Infoblox database
#     should result in an Infoblox::Host.delete
#  end
#  describe '#next_ip' do
#     takes the network specified by config[:network] (and optionally the range specified by config[:exclude])
#     performs a short series of calculations to create a usable IP range for excluding
#     returns the next available IP from the network that does not fall inside the excluded range
#  end
end
