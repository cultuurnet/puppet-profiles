require 'spec_helper'

describe 'profiles::deployment::uit::frontend' do
  context "with config_source => /foo" do
    let (:params) { {
      'config_source'     => '/foo'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__apt__update('publiq-uit') }

        it { is_expected.to contain_package('uit-frontend').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uit-frontend').that_notifies('Profiles::Deployment::Versions[profiles::deployment::uit::frontend]') }
        it { is_expected.to contain_package('uit-frontend').that_requires('Profiles::Apt::Update[publiq-uit]') }

        it { is_expected.to contain_file('uit-frontend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-frontend/packages/app/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uit-frontend-config').that_requires('Package[uit-frontend]') }

        it { is_expected.not_to contain_file('/etc/default/uit-frontend') }

        it { is_expected.to contain_service('uit-frontend').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('uit-frontend').that_requires('Package[uit-frontend]') }
        it { is_expected.to contain_file('uit-frontend-config').that_notifies('Service[uit-frontend]') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uit::frontend').with(
          'project'      => 'uit',
          'packages'     => 'uit-frontend',
          'puppetdb_url' => nil
        ) }

        context "with service_manage => false" do
          let (:params) {
            super().merge({
              'service_manage' => false
            } )
          }

          it { is_expected.not_to contain_service('uit-frontend') }
        end
      end
    end
  end

  context "with config_source => /bar, version => 1.2.3, service_defaults_source => /baz, service_ensure => stopped, service_enable = false and puppetdb_url => http://example.com:8000" do
    let (:params) { {
      'config_source'           => '/bar',
      'version'                 => '1.2.3',
      'service_ensure'          => 'stopped',
      'service_defaults_source' => '/baz',
      'service_enable'          => false,
      'puppetdb_url'            => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to contain_file('uit-frontend-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_file('uit-frontend-service-defaults').with(
          'ensure' => 'file',
          'path'   => '/etc/default/uit-frontend',
          'source' => '/baz',
          'owner'  => 'root',
          'group'  => 'root'
        ) }

        it { is_expected.to contain_package('uit-frontend').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_service('uit-frontend').with(
          'ensure'    => 'stopped',
          'enable'    => false
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uit::frontend').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }

        it { is_expected.to contain_file('uit-frontend-service-defaults').that_notifies('Service[uit-frontend]') }
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
