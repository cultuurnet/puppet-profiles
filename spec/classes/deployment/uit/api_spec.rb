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

        it { is_expected.to contain_package('uitbe-api').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uitbe-api').that_notifies('Profiles::Deployment::Versions[profiles::deployment::uit::api]') }
        it { is_expected.to contain_package('uitbe-api').that_requires('Profiles::Apt::Update[publiq-uit]') }

        it { is_expected.to contain_file('uitbe-api-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uitbe-api/packages/graphql/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitbe-api-config').that_requires('Package[uitbe-api]') }

        it { is_expected.to contain_service('uitbe-api').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('uitbe-api').that_requires('Package[uitbe-api]') }
        it { is_expected.to contain_file('uitbe-api-config').that_notifies('Service[uitbe-api]') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uit::api').with(
          'project'      => 'uit',
          'packages'     => 'uitbe-api',
          'puppetdb_url' => nil
        ) }

        context "with service_manage => false" do
          let (:params) {
            super().merge({
              'service_manage' => false
            } )
          }

          it { is_expected.not_to contain_service('uitbe-api') }
        end
      end
    end
  end

  context "with config_source => /bar, package_version => 1.2.3, service_ensure => stopped, service_enable = false and puppetdb_url => http://example.com:8000" do
    let (:params) { {
      'config_source'       => '/bar',
      'package_version'     => '1.2.3',
      'service_ensure'      => 'stopped',
      'service_enable'      => false,
      'puppetdb_url'        => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to contain_file('uitbe-api-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_package('uitbe-api').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_service('uitbe-api').with(
          'ensure'    => 'stopped',
          'enable'    => false
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uit::api').with(
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
