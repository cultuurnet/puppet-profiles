RSpec.configure do |rspec|
  rspec.mock_with :rspec
  rspec.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
  rspec.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

add_custom_fact :staging_http_get, 'curl'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
