describe 'profiles::uitdatabank::websocket_server' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with servername => sockets.example.com' do
        let(:params) { {
          'servername' => 'sockets.example.com'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'without extra parameters' do
            let(:params) { super().merge({}) }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitdatabank::websocket_server').with(
              'servername'      => 'sockets.example.com',
              'serveraliases'   => [],
              'deployment'      => true,
              'service_address' => '127.0.0.1',
              'service_port'    => 3000
            ) }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }

            it { is_expected.to contain_file('/var/www/udb3-websocket-server').with(
              'ensure' => 'directory',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.to contain_class('profiles::nodejs') }
            it { is_expected.to contain_class('profiles::redis') }

            it { is_expected.to contain_class('profiles::uitdatabank::websocket_server::deployment').with(
              'service_address' => '127.0.0.1',
              'service_port'    => 3000
            ) }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://sockets.example.com').with(
              'aliases'            => [],
              'destination'        => 'http://127.0.0.1:3000/',
              'support_websockets' => true
            ) }

            it { is_expected.to contain_file('/var/www/udb3-websocket-server').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('/var/www/udb3-websocket-server').that_requires('User[www-data]') }
            it { is_expected.to contain_class('profiles::uitdatabank::websocket_server::deployment').that_requires('Class[profiles::nodejs]') }
            it { is_expected.to contain_class('profiles::uitdatabank::websocket_server::deployment').that_requires('Class[profiles::redis]') }
            it { is_expected.to contain_class('profiles::uitdatabank::websocket_server::deployment').that_comes_before('Profiles::Apache::Vhost::Reverse_proxy[http://sockets.example.com]') }
          end

          context 'with serveraliases => [foo.example.com, bar.example.com], service_address => 0.0.0.0 and service_port => 4000' do
            let(:params) { super().merge({
              'serveraliases'   => ['foo.example.com', 'bar.example.com'],
              'service_address' => '0.0.0.0',
              'service_port'    => 4000
            }) }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitdatabank::websocket_server::deployment').with(
              'service_address' => '0.0.0.0',
              'service_port'    => 4000
            ) }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://sockets.example.com').with(
              'aliases'            => ['foo.example.com', 'bar.example.com'],
              'destination'        => 'http://0.0.0.0:4000/',
              'support_websockets' => true
            ) }
          end

          context 'with deployment => false' do
            let(:params) { super().merge({
              'deployment' => false
            }) }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::nodejs') }
            it { is_expected.to contain_class('profiles::redis') }

            it { is_expected.to_not contain_class('profiles::uitdatabank::websocket_server::deployment') }
          end
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
