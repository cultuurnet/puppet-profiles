RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |c|
  c.default_facts = { 'staging_http_get' =>  'curl' }
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
