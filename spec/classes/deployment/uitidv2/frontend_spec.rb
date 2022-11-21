require 'spec_helper'

describe 'profiles::deployment::uitidv2::frontend' do
  context "with config_source => /foo" do
    let(:params) { {
      'config_source'     => '/foo'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('uitid-frontend') }

        it { is_expected.to contain_package('uitid-frontend').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uitid-frontend').that_notifies('Profiles::Deployment::Versions[profiles::deployment::uitidv2::frontend]') }
        it { is_expected.to contain_package('uitid-frontend').that_requires('Apt::Source[uitid-frontend]') }

        it { is_expected.to contain_file('uitid-frontend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uitid-frontend/app/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitid-frontend-config').that_requires('Package[uitid-frontend]') }

        it { is_expected.not_to contain_file('/etc/defaults/uitid-frontend') }

        it { is_expected.to contain_service('uitid-frontend').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('uitid-frontend').that_requires('Package[uitid-frontend]') }
        it { is_expected.to contain_file('uitid-frontend-config').that_notifies('Service[uitid-frontend]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uitidv2::frontend').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uitidv2::frontend').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end

        context "with service_manage => false" do
          let(:params) {
            super().merge({
              'service_manage' => false
            } )
          }

          it { is_expected.not_to contain_service('uitid-frontend') }
        end
      end
    end
  end

  context "with config_source => /bar, version => 1.2.3, env_defaults_source => /tmp/a, service_ensure => stopped, service_enable = false and puppetdb_url => http://example.com:8000" do
    let(:params) { {
      'config_source'       => '/bar',
      'version'             => '1.2.3',
      'env_defaults_source' => '/tmp/a',
      'service_ensure'      => 'stopped',
      'service_enable'      => false,
      'puppetdb_url'        => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to contain_file('uitid-frontend-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_package('uitid-frontend').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_service('uitid-frontend').with(
          'ensure'    => 'stopped',
          'enable'    => false
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uitidv2::frontend').with(
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

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
