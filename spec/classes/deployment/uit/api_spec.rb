require 'spec_helper'

describe 'profiles::deployment::uit::api' do
  context "with config_source => /foo" do
    let (:params) { {
      'config_source'     => '/foo'
    } }

    include_examples 'operating system support', 'profiles::deployment::uit::api'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('publiq-uit') }
        it { is_expected.to contain_profiles__apt__update('publiq-uit') }

        it { is_expected.to contain_package('yarn') }

        it { is_expected.to contain_package('uit-api').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uit-api').that_notifies('Profiles::Deployment::Versions[profiles::deployment::uit::api]') }
        it { is_expected.to contain_package('uit-api').that_requires('Profiles::Apt::Update[publiq-uit]') }

        it { is_expected.to contain_file('uit-api-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-api/packages/graphql/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uit-api-config').that_requires('Package[uit-api]') }

        it { is_expected.not_to contain_file('/etc/default/uit-api') }

        it { is_expected.to contain_exec('uit-api_db_schema_update').with(
          'command'     => 'yarn graphql typeorm migration:run',
          'cwd'         => '/var/www/uit-api',
          'user'        => 'www-data',
          'group'       => 'www-data',
          'path'        => [ '/usr/local/bin', '/usr/bin', '/bin', '/var/www/uit-api'],
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('uit-api_db_schema_update').that_subscribes_to('Package[uit-api]') }
        it { is_expected.to contain_exec('uit-api_db_schema_update').that_subscribes_to('File[uit-api-config]') }
        it { is_expected.to contain_exec('uit-api_db_schema_update').that_requires('Package[yarn]') }

        it { is_expected.to contain_service('uit-api').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('uit-api').that_requires('Package[uit-api]') }
        it { is_expected.to contain_file('uit-api-config').that_notifies('Service[uit-api]') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uit::api').with(
          'project'      => 'uit',
          'packages'     => 'uit-api',
          'puppetdb_url' => nil
        ) }

        context "with service_manage => false" do
          let (:params) {
            super().merge({
              'service_manage' => false
            } )
          }

          it { is_expected.not_to contain_service('uit-api') }
        end
      end
    end
  end

  context "with config_source => /bar, package_version => 1.2.3, service_defaults_source => /baz, service_ensure => stopped, service_enable = false and puppetdb_url => http://example.com:8000" do
    let (:params) { {
      'config_source'           => '/bar',
      'package_version'         => '1.2.3',
      'service_ensure'          => 'stopped',
      'service_defaults_source' => '/baz',
      'service_enable'          => false,
      'puppetdb_url'            => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to contain_file('uit-api-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_file('uit-api-service-defaults').with(
          'ensure' => 'file',
          'path'   => '/etc/default/uit-api',
          'source' => '/baz',
          'owner'  => 'root',
          'group'  => 'root'
        ) }

        it { is_expected.to contain_package('uit-api').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_service('uit-api').with(
          'ensure'    => 'stopped',
          'enable'    => false
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uit::api').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }

        it { is_expected.to contain_file('uit-api-service-defaults').that_notifies('Service[uit-api]') }
      end
    end
  end

  context "without parameters" do
    let (:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
