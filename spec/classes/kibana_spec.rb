describe 'profiles::kibana' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with servername => kibana.example.com' do
          let(:params) { {
            'servername' => 'kibana.example.com'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::kibana').with(
            'servername'      => 'kibana.example.com',
            'serveraliases'   => [],
            'version'         => 'latest',
            'service_address' => '127.0.0.1',
            'service_port'    => 5601,
            'service_status'  => 'running'
          ) }

          it { is_expected.to contain_group('kibana') }
          it { is_expected.to contain_user('kibana') }

          it { is_expected.to contain_apt__source('elastic-8.x') }

          it { is_expected.to contain_package('kibana').with(
            'ensure' => 'latest'
          ) }

          it { is_expected.to contain_file('kibana config').with(
            'ensure'  => 'file',
            'path'    => '/etc/kibana/kibana.yml'
          ) }

          it { is_expected.to contain_file('kibana config').with_content(/^server.host: 127.0.0.1$/) }
          it { is_expected.to contain_file('kibana config').with_content(/^server.port: 5601$/) }
          it { is_expected.to contain_file('kibana config').with_content(/^server.publicBaseUrl: https:\/\/kibana\.example\.com$/) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://kibana.example.com').with(
            'destination'         => 'http://127.0.0.1:5601/',
            'aliases'             => [],
            'preserve_host'       => true,
            'auth_openid_connect' => true
          ) }

          it { is_expected.to contain_service('kibana').with(
            'ensure'    => 'running',
            'enable'    => true,
            'hasstatus' => true
          ) }

          it { is_expected.to contain_group('kibana').that_comes_before('Package[kibana]') }
          it { is_expected.to contain_user('kibana').that_comes_before('Package[kibana]') }
          it { is_expected.to contain_apt__source('elastic-8.x').that_comes_before('Package[kibana]') }
          it { is_expected.to contain_file('kibana config').that_requires('Package[kibana]') }
          it { is_expected.to contain_file('kibana config').that_notifies('Service[kibana]') }
          it { is_expected.to contain_service('kibana').that_subscribes_to('Package[kibana]') }
        end

        context 'with servername => mykibana.com, serveraliases => [foo.example.com, bar.example.com], version => 1.2.3, service_address => 0.0.0.0, service_port => 5602 and service_status => stopped' do
          let(:params) { {
            'servername'      => 'mykibana.com',
            'serveraliases'   => ['foo.example.com', 'bar.example.com'],
            'version'         => '1.2.3',
            'service_address' => '0.0.0.0',
            'service_port'    => 5602,
            'service_status'  => 'stopped'
          } }

          it { is_expected.to contain_package('kibana').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_file('kibana config').with(
            'ensure'  => 'file',
            'path'    => '/etc/kibana/kibana.yml'
          ) }

          it { is_expected.to contain_file('kibana config').with_content(/^server.host: 0.0.0.0$/) }
          it { is_expected.to contain_file('kibana config').with_content(/^server.port: 5602$/) }
          it { is_expected.to contain_file('kibana config').with_content(/^server.publicBaseUrl: https:\/\/mykibana\.com$/) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://mykibana.com').with(
            'destination'         => 'http://0.0.0.0:5602/',
            'aliases'             => ['foo.example.com', 'bar.example.com'],
            'preserve_host'       => true,
            'auth_openid_connect' => true
          ) }

          it { is_expected.to contain_service('kibana').with(
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
end
