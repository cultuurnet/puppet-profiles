require 'rspec-puppet'
require 'rspec-puppet-facts'

RSpec.configure do |rspec|
  rspec.module_path = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'modules')

  rspec.order = 'random'
  rspec.mock_with :rspec

  rspec.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end

  rspec.before(:each) do
    # The systemd service provider is confined to platforms that are running systemd,
    # by checking the presence and contents of the file '/proc/1/comm'.
    # This makes sense for a real puppet agent, but breaks when running spec tests on
    # a platform that does not use systemd (like MacOS). We mock the calls the confine
    # statement makes on all platforms to simulate running systemd.
    #
    # For more information, see: https://tickets.puppetlabs.com/browse/PUP-11167
    allow(Puppet::FileSystem).to receive(:exist?).and_call_original
    allow(Puppet::FileSystem).to receive(:exist?).with('/proc/1/comm').and_return(true)
    allow(Puppet::FileSystem).to receive(:read).and_call_original
    allow(Puppet::FileSystem).to receive(:read).with('/proc/1/comm').and_return(['systemd'])
    # Pretend to be running as root
    allow(Puppet.features).to receive(:root?).and_return(true)
  end

  rspec.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end

include RspecPuppetFacts

add_custom_fact :staging_http_get, 'curl'
add_custom_fact :service_provider, 'systemd', :confine => ['ubuntu-20.04-x86_64', 'ubuntu-24.04-x86_64']

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
