RSpec.configure do |c|
  c.mock_with :rspec
end

require 'rspec-puppet-facts'
require 'puppetlabs_spec_helper/module_spec_helper'

include RspecPuppetFacts

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |c|
  c.default_facts = { 'staging_http_get' =>  'curl' }
  c.mock_with :rspec
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
