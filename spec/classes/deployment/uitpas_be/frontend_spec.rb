require 'spec_helper'

describe 'profiles::deployment::uitpas_be::frontend' do
  context "with config_source => /foo" do
    let (:params) { {
      'config_source'     => '/foo'
    } }

    include_examples 'operating system support', 'profiles::deployment::uitpas_be::frontend'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__apt__update('publiq-uitpasbe') }

        it { is_expected.to contain_package('uitpasbe-frontend').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uitpasbe-frontend').that_notifies('Profiles::Deployment::Versions[profiles::deployment::uitpas_be::frontend]') }
        it { is_expected.to contain_package('uitpasbe-frontend').that_requires('Profiles::Apt::Update[publiq-uitpasbe]') }

        it { is_expected.to contain_file('uitpasbe-frontend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uitpasbe-frontend/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitpasbe-frontend-config').that_requires('Package[uitpasbe-frontend]') }

        it { is_expected.not_to contain_file('/etc/defaults/uitpasbe-frontend') }

        it { is_expected.to contain_service('uitpasbe-frontend').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('uitpasbe-frontend').that_requires('Package[uitpasbe-frontend]') }
        it { is_expected.to contain_file('uitpasbe-frontend-config').that_notifies('Service[uitpasbe-frontend]') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uitpas_be::frontend').with(
          'project'      => 'uitpasbe',
          'packages'     => 'uitpasbe-frontend',
          'puppetdb_url' => nil
        ) }

        context "with service_manage => false" do
          let (:params) {
            super().merge({
              'service_manage' => false
            } )
          }

          it { is_expected.not_to contain_service('uitpasbe-frontend') }
        end
      end
    end
  end

  context "with config_source => /bar, package_version => 1.2.3, env_defaults_source => /tmp/a, service_ensure => stopped, service_enable = false and puppetdb_url => http://example.com:8000" do
    let (:params) { {
      'config_source'       => '/bar',
      'package_version'     => '1.2.3',
      'env_defaults_source' => '/tmp/a',
      'service_ensure'      => 'stopped',
      'service_enable'      => false,
      'puppetdb_url'        => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to contain_file('uitpasbe-frontend-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_package('uitpasbe-frontend').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_service('uitpasbe-frontend').with(
          'ensure'    => 'stopped',
          'enable'    => false
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uitpas_be::frontend').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }
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
