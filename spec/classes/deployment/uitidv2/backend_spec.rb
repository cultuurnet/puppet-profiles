require 'spec_helper'

describe 'profiles::deployment::uitidv2::backend' do
  context "with config_source => /foo" do
    let (:params) { {
      'config_source'     => '/foo'
    } }

    include_examples 'operating system support', 'profiles::deployment::uitidv2::backend'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__apt__update('publiq-uitidv2') }

        it { is_expected.to contain_package('uitid-backend').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uitid-backend').that_notifies('Profiles::Deployment::Versions[profiles::deployment::uitidv2::backend]') }
        it { is_expected.to contain_package('uitid-backend').that_requires('Profiles::Apt::Update[publiq-uitidv2]') }

        it { is_expected.to contain_file('uitid-backend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uitid-backend/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitid-backend-config').that_requires('Package[uitid-backend]') }

        it { is_expected.not_to contain_file('/etc/defaults/uitid-backend') }

        it { is_expected.to contain_service('uitid-backend').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('uitid-backend').that_requires('Package[uitid-backend]') }
        it { is_expected.to contain_file('uitid-backend-config').that_notifies('Service[uitid-backend]') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uitidv2::backend').with(
          'project'      => 'uitid',
          'packages'     => 'uitid-backend',
          'puppetdb_url' => nil
        ) }

        context "with service_manage => false" do
          let (:params) {
            super().merge({
              'service_manage' => false
            } )
          }

          it { is_expected.not_to contain_service('uitid-backend') }
        end
      end
    end
  end

  context "with config_source => /bar, version => 1.2.3, env_defaults_source => /tmp/a, service_ensure => stopped, service_enable = false and puppetdb_url => http://example.com:8000" do
    let (:params) { {
      'config_source'       => '/bar',
      'version'             => '1.2.3',
      'env_defaults_source' => '/tmp/a',
      'service_ensure'      => 'stopped',
      'service_enable'      => false,
      'puppetdb_url'        => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to contain_file('uitid-backend-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_package('uitid-backend').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_service('uitid-backend').with(
          'ensure'    => 'stopped',
          'enable'    => false
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uitidv2::backend').with(
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
