describe 'profiles::grafana' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with servername => grafana.example.com' do
        let(:params) { {
          'servername' => 'grafana.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::grafana').with(
          'servername'      => 'grafana.example.com',
          'serveraliases'   => [],
          'version'         => 'latest',
          'service_address' => '127.0.0.1',
          'service_port'    => 3000,
          'service_status'  => 'running'
        ) }

        it { is_expected.to contain_group('grafana') }
        it { is_expected.to contain_user('grafana') }

        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_package('grafana').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('grafana config').with(
          'ensure'  => 'file',
          'path'    => '/etc/grafana/grafana.ini',
          'content' => "[server]\nprotocol = http\nhttp_addr = 127.0.0.1\nhttp_port = 3000"
        ) }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://grafana.example.com').with(
          'destination'   => 'http://127.0.0.1:3000/',
          'aliases'       => [],
          'preserve_host' => true
        ) }

        it { is_expected.to contain_service('grafana-server').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_group('grafana').that_comes_before('Package[grafana]') }
        it { is_expected.to contain_user('grafana').that_comes_before('Package[grafana]') }
        it { is_expected.to contain_apt__source('publiq-tools').that_comes_before('Package[grafana]') }
        it { is_expected.to contain_file('grafana config').that_requires('Package[grafana]') }
        it { is_expected.to contain_file('grafana config').that_notifies('Service[grafana-server]') }
        it { is_expected.to contain_service('grafana-server').that_subscribes_to('Package[grafana]') }
      end

      context 'with servername => mygrafana.com, serveraliases => [foo.example.com, bar.example.com], version => 1.2.3, service_address => 0.0.0.0, service_port => 3001 and service_status => stopped' do
        let(:params) { {
          'servername'      => 'mygrafana.com',
          'serveraliases'   => ['foo.example.com', 'bar.example.com'],
          'version'         => '1.2.3',
          'service_address' => '0.0.0.0',
          'service_port'    => 3001,
          'service_status'  => 'stopped'
        } }

        it { is_expected.to contain_package('grafana').with(
          'ensure' => '1.2.3'
        ) }

        it { is_expected.to contain_file('grafana config').with(
          'ensure'  => 'file',
          'path'    => '/etc/grafana/grafana.ini',
          'content' => "[server]\nprotocol = http\nhttp_addr = 0.0.0.0\nhttp_port = 3001"
        ) }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://mygrafana.com').with(
          'destination'   => 'http://0.0.0.0:3001/',
          'aliases'       => ['foo.example.com', 'bar.example.com'],
          'preserve_host' => true
        ) }

        it { is_expected.to contain_service('grafana-server').with(
          'ensure'    => 'stopped',
          'enable'    => false,
          'hasstatus' => true
        ) }

      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
