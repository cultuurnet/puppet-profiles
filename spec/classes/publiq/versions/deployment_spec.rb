require 'spec_helper'

describe 'profiles::publiq::versions::deployment' do

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::publiq::versions::deployment').with(
          'version'         => 'latest',
          'service_address' => '127.0.0.1',
          'service_port'    => 3000,
          'puppetdb_url'    => nil
        ) }

        it { is_expected.to contain_apt__source('publiq-versions') }

        it { is_expected.to contain_package('publiq-versions').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('publiq-versions').that_notifies('Profiles::Deployment::Versions[profiles::publiq::versions::deployment]') }
        it { is_expected.to contain_package('publiq-versions').that_notifies('Class[profiles::publiq::versions::service]') }
        it { is_expected.to contain_package('publiq-versions').that_requires('Apt::Source[publiq-versions]') }

        it { is_expected.to contain_file('publiq-versions-env').with(
          'ensure' => 'file',
          'path'   => '/var/www/publiq-versions/.env',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('publiq-versions-env').with_content('PUPPETDB_CONFIG_SOURCE=\'/var/www/.puppetlabs/client-tools/puppetdb.conf\'') }

        it { is_expected.to contain_file('publiq-versions-env').that_notifies('Class[profiles::publiq::versions::service]') }

        it { is_expected.to contain_file('publiq-versions-service-defaults').with(
          'ensure' => 'file',
          'path'   => '/etc/default/publiq-versions',
          'owner'  => 'root',
          'group'  => 'root'
        ) }

        it { is_expected.to contain_file('publiq-versions-service-defaults').with_content(/^LISTEN_ADDRESS=127\.0\.0\.1$/) }
        it { is_expected.to contain_file('publiq-versions-service-defaults').with_content(/^LISTEN_PORT=3000$/) }

        it { is_expected.to contain_file('publiq-versions-service-defaults').that_notifies('Class[profiles::publiq::versions::service]') }

        it { is_expected.to contain_class('profiles::publiq::versions::service') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::versions::deployment').with(
          'project'      => 'publiq',
          'packages'     => 'publiq-versions',
          'puppetdb_url' => nil
        ) }
      end

      context "with version => 1.2.3, service_defaults_source => /baz, service_address => 0.0.0.0, service_port => 5000 and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'version'         => '1.2.3',
          'service_address' => '0.0.0.0',
          'service_port'    => 5000,
          'puppetdb_url'    => 'http://example.com:8000'
        } }

        it { is_expected.to contain_package('publiq-versions').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_file('publiq-versions-service-defaults').with_content(/^LISTEN_ADDRESS=0\.0\.0\.0$/) }
        it { is_expected.to contain_file('publiq-versions-service-defaults').with_content(/^LISTEN_PORT=5000$/) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::versions::deployment').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }
      end
    end
  end
end
