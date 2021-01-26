require 'spec_helper'

describe 'profiles::puppetdb::cli' do
  context "on node1.example.com with server_urls => https://example.com:1234" do
    let (:node) { 'node1.example.com' }
    let (:params) { {
      'server_urls'     => 'https://example.com:1234'
    } }

    include_examples 'operating system support', 'profiles::puppetdb::cli'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__apt__update('cultuurnet-tools') }

        it { is_expected.to contain_package('rubygem-puppetdb-cli') }
        it { is_expected.to contain_file('puppetdb-cli-config').with(
          'ensure' => 'file',
          'path'   => '/etc/puppetlabs/client-tools/puppetdb.conf',
        )}

        it { is_expected.to contain_file('puppetdb-cli-config').with_content(/"server_urls":\s*"https:\/\/example.com:1234"/) }
        it { is_expected.to contain_file('puppetdb-cli-config').with_content(/"cacert":\s*"\/etc\/puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
        it { is_expected.to contain_file('puppetdb-cli-config').with_content(/"cert":\s*"\/etc\/puppetlabs\/puppet\/ssl\/certs\/node1.example.com.pem"/) }
        it { is_expected.to contain_file('puppetdb-cli-config').with_content(/"key":\s*"\/etc\/puppetlabs\/puppet\/ssl\/private_keys\/node1.example.com.pem"/) }

        it { is_expected.to contain_package('rubygem-puppetdb-cli').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }
      end
    end
  end

  context "on node2.example.com with server_urls => [ https://example.com:1234, https://example.com:5678]" do
    let (:node) { 'node2.example.com' }
    let (:params) { {
      'server_urls'     => [ 'https://example.com:1234', 'https://example.com:5678']
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to contain_file('puppetdb-cli-config').with_content(/"server_urls":\s*\[\s*"https:\/\/example.com:1234",\s*"https:\/\/example.com:5678"\s*\]/) }
        it { is_expected.to contain_file('puppetdb-cli-config').with_content(/"cert":\s*"\/etc\/puppetlabs\/puppet\/ssl\/certs\/node2.example.com.pem"/) }
        it { is_expected.to contain_file('puppetdb-cli-config').with_content(/"key":\s*"\/etc\/puppetlabs\/puppet\/ssl\/private_keys\/node2.example.com.pem"/) }
      end
    end
  end

  context "without parameters" do
    let (:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'server_urls'/) }
      end
    end
  end
end
