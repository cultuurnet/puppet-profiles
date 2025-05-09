describe 'profiles::uitdatabank::websocket_server::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => appconfig/uitdatabank/udb3-websocket-server/config.json' do
        let(:params) { {
          'config_source' => 'appconfig/uitdatabank/udb3-websocket-server/config.json'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::websocket_server::deployment').with(
            'config_source'   => 'appconfig/uitdatabank/udb3-websocket-server/config.json',
            'version'         => 'latest',
            'repository'      => 'uitdatabank-websocket-server',
            'service_status'  => 'running',
            'service_address' => '127.0.0.1',
            'service_port'    => 3000,
            'puppetdb_url'    => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_apt__source('uitdatabank-websocket-server') }

          it { is_expected.to contain_package('uitdatabank-websocket-server').with( 'ensure' => 'latest') }
          it { is_expected.to contain_package('uitdatabank-websocket-server').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::websocket_server::deployment]') }
          it { is_expected.to contain_package('uitdatabank-websocket-server').that_requires('Apt::Source[uitdatabank-websocket-server]') }

          it { is_expected.to contain_file('uitdatabank-websocket-server-config').with(
            'ensure' => 'file',
            'path'   => '/var/www/udb3-websocket-server/config.json',
            'owner'  => 'www-data',
            'group'  => 'www-data'
          ) }

          it { is_expected.to contain_file('uitdatabank-websocket-server-service-defaults').with(
            'ensure'  => 'file',
            'path'    => '/etc/default/uitdatabank-websocket-server',
            'content' => "HOST=127.0.0.1\nPORT=3000"
          ) }

          it { is_expected.to contain_file('uitdatabank-websocket-server-config').that_requires('Package[uitdatabank-websocket-server]') }
          it { is_expected.to contain_file('uitdatabank-websocket-server-service-defaults').that_requires('Package[uitdatabank-websocket-server]') }

          it { is_expected.to contain_service('uitdatabank-websocket-server').with(
            'ensure'    => 'running',
            'enable'    => true,
            'hasstatus' => true
          ) }

          it { is_expected.to contain_package('uitdatabank-websocket-server').that_comes_before('File[uitdatabank-websocket-server-config]') }
          it { is_expected.to contain_package('uitdatabank-websocket-server').that_comes_before('File[uitdatabank-websocket-server-service-defaults]') }
          it { is_expected.to contain_service('uitdatabank-websocket-server').that_subscribes_to('Package[uitdatabank-websocket-server]') }
          it { is_expected.to contain_service('uitdatabank-websocket-server').that_subscribes_to('File[uitdatabank-websocket-server-config]') }
          it { is_expected.to contain_service('uitdatabank-websocket-server').that_subscribes_to('File[uitdatabank-websocket-server-service-defaults]') }
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::websocket_server::deployment').with(
            'puppetdb_url' => nil
          ) }
        end
      end

      context 'with config_source => appconfig/uitdatabank/udb3-websocket-server/config.json, version => 1.2.3, repository => uitdatabank-websocket-server-alternative, service_address => 0.0.0.0, service_port => 5000, service_status => stopped and puppetdb_url => http://example.com:8000' do
        let(:params) { {
          'config_source'   => 'appconfig/uitdatabank/udb3-websocket-server/config.json',
          'version'         => '1.2.3',
          'repository'      => 'uitdatabank-websocket-server-alternative',
          'service_status'  => 'stopped',
          'service_address' => '0.0.0.0',
          'service_port'    => 5000,
          'puppetdb_url'    => 'http://example.com:8000'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'with repository uitdatabank-websocket-server-alternative defined' do
            let(:pre_condition) { '@apt::source { "uitdatabank-websocket-server-alternative": location => "http://localhost", release => "focal", repos => "main" }' }

            it { is_expected.to contain_apt__source('uitdatabank-websocket-server-alternative') }

            it { is_expected.to contain_package('uitdatabank-websocket-server').with('ensure' => '1.2.3') }

            it { is_expected.to contain_file('uitdatabank-websocket-server-service-defaults').with(
              'ensure'  => 'file',
              'path'    => '/etc/default/uitdatabank-websocket-server',
              'content' => "HOST=0.0.0.0\nPORT=5000"
            ) }

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

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
