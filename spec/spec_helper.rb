RSpec.configure do |rspec|
  rspec.mock_with :rspec
  rspec.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
  rspec.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
  # The systemd service provider is confined to platforms that are running systemd,
  # by checking the presence and contents of the file '/proc/1/comm'.
  # This makes sense for a real puppet agent, but breaks when running spec tests on
  # a platform that does not use systemd (like MacOS). We mock the calls the confine
  # statement makes to simulate running systemd.
  #
  # For more information, see: https://tickets.puppetlabs.com/browse/PUP-11167
  if RUBY_PLATFORM =~ /darwin/i
    rspec.before(:each) do
      allow(Puppet::FileSystem).to receive(:exist?).and_call_original
      allow(Puppet::FileSystem).to receive(:exist?).with('/proc/1/comm').and_return(true)
      allow(Puppet::FileSystem).to receive(:read).and_call_original
      allow(Puppet::FileSystem).to receive(:read).with('/proc/1/comm').and_return(['systemd'])
    end
  end
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

add_custom_fact :staging_http_get, 'curl'
add_custom_fact :service_provider, 'systemd', :confine => 'ubuntu-20.04-x86_64'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
