require 'spec_helper'

describe 'profiles::uitdatabank::websocket_server::deployment' do
  context "with config_source => /foo.json" do
    let(:params) { {
      'config_source' => '/foo.json'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::websocket_server::deployment').with(
          'config_source'  => '/foo.json',
          'version'        => 'latest',
          'service_manage' => true,
          'service_ensure' => 'running',
          'service_enable' => true,
          'listen_port'    => 3000,
          'puppetdb_url'   => nil
        ) }

        it { is_expected.to contain_apt__source('uitdatabank-websocket-server') }

        it { is_expected.to contain_package('uitdatabank-websocket-server').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uitdatabank-websocket-server').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::websocket_server::deployment]') }
        it { is_expected.to contain_package('uitdatabank-websocket-server').that_requires('Apt::Source[uitdatabank-websocket-server]') }

        it { is_expected.to contain_file('uitdatabank-websocket-server-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/udb3-websocket-server/config.json',
          'source' => '/foo.json',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitdatabank-websocket-server-service-defaults').with(
          'ensure'  => 'file',
          'path'    => '/etc/default/uitdatabank-websocket-server',
          'content' => 'PORT=3000'
        ) }

        it { is_expected.to contain_file('uitdatabank-websocket-server-config').that_requires('Package[uitdatabank-websocket-server]') }
        it { is_expected.to contain_file('uitdatabank-websocket-server-service-defaults').that_requires('Package[uitdatabank-websocket-server]') }

        it { is_expected.to contain_service('uitdatabank-websocket-server').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('uitdatabank-websocket-server').that_subscribes_to('Package[uitdatabank-websocket-server]') }
        it { is_expected.to contain_service('uitdatabank-websocket-server').that_subscribes_to('File[uitdatabank-websocket-server-config]') }
        it { is_expected.to contain_service('uitdatabank-websocket-server').that_subscribes_to('File[uitdatabank-websocket-server-service-defaults]') }

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::websocket_server::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::websocket_server::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end

        context "with service_manage => false" do
          let(:params) {
            super().merge({
              'service_manage' => false
            } )
          }

          it { is_expected.not_to contain_file('uitdatabank-websocket-server-service-defaults') }
          it { is_expected.not_to contain_service('uitdatabank-websocket-server') }
        end
      end
    end
  end

  context "with config_source => /bar.json, version => 1.2.3, service_ensure => stopped, service_enable = false and puppetdb_url => http://example.com:8000" do
    let(:params) { {
      'config_source'           => '/bar.json',
      'version'                 => '1.2.3',
      'service_ensure'          => 'stopped',
      'service_enable'          => false,
      'puppetdb_url'            => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to contain_file('uitdatabank-websocket-server-config').with(
          'source' => '/bar.json',
        ) }

        it { is_expected.to contain_package('uitdatabank-websocket-server').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_service('uitdatabank-websocket-server').with(
          'ensure'    => 'stopped',
          'enable'    => false
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::websocket_server::deployment').with(
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
