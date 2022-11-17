require 'spec_helper'

describe 'profiles::deployment::uit::notifications' do
  context "with settings_source => /foo" do
    let(:params) { {
      'settings_source'       => '/foo',
      'aws_access_key_id'     => 'secret_key_id',
      'aws_secret_access_key' => 'secret_access_key'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('uit-notifications') }

        it { is_expected.to contain_package('uit-notifications').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uit-notifications').that_notifies('Profiles::Deployment::Versions[profiles::deployment::uit::notifications]') }
        it { is_expected.to contain_package('uit-notifications').that_requires('Apt::Source[uit-notifications]') }

        it { is_expected.to contain_file('uit-notifications-settings').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-notifications/packages/notifications/env.yml',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uit-notifications-settings').that_requires('Package[uit-notifications]') }

        it { is_expected.not_to contain_file('/etc/default/uit-notifications') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uit::notifications').with(
          'puppetdb_url' => nil
        ) }
      end
    end
  end

  context "with settings_source => /bar, version => 1.2.3 and puppetdb_url => http://example.com:8000" do
    let(:params) { {
      'settings_source'         => '/bar',
      'aws_access_key_id'       => 'secret_key_id',
      'aws_secret_access_key'   => 'secret_access_key',
      'version'                 => '1.2.3',
      'puppetdb_url'            => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to contain_file('uit-notifications-settings').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_package('uit-notifications').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uit::notifications').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }
      end
    end
  end

  context "without parameters" do
    let(:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'settings_source'/) }
      end
    end
  end
end
