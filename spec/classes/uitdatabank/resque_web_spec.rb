describe 'profiles::uitdatabank::resque_web' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with servername => app.example.com' do
          let(:params) { {
            'servername' => 'app.example.com'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::resque_web').with(
            'servername'      => 'app.example.com',
            'serveraliases'   => [],
            'service_address' => '127.0.0.1',
            'service_port'    => '5678'
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }
          it { is_expected.to contain_apt__source('publiq-tools') }

          it { is_expected.to contain_package('resque-web').with(
            'ensure' => 'installed'
          ) }

          it { is_expected.to contain_class('profiles::apache') }
          it { is_expected.to contain_class('profiles::redis') }

          it { is_expected.to contain_file('resque-web-service-defaults').with(
            'ensure' => 'file',
            'path'   => '/etc/default/resque-web'
          ) }

          it { is_expected.to contain_file('resque-web-service-defaults').with_content(/^HOST=127.0.0.1\nPORT=5678$/) }

          it { is_expected.to contain_service('resque-web').with(
            'ensure'    => 'running',
            'enable'    => true,
            'hasstatus' => true
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://app.example.com').with(
            'aliases'             => [],
            'destination'         => 'http://127.0.0.1:5678/',
            'auth_openid_connect' => true
          ) }

          it { is_expected.to contain_package('resque-web').that_requires('Apt::Source[publiq-tools]') }
          it { is_expected.to contain_file('resque-web-service-defaults').that_notifies('Service[resque-web]') }
          it { is_expected.to contain_service('resque-web').that_requires('Class[profiles::redis]') }
        end

        context 'with servername => jobs.example.com, serveraliases => [www.example.com, old.example.com], service_address => 0.0.0.0 and service_port => 1234' do
          let(:params) { {
            'servername'      => 'jobs.example.com',
            'serveraliases'   => ['www.example.com', 'old.example.com'],
            'service_address' => '0.0.0.0',
            'service_port'    => 1234
          } }

          it { is_expected.to contain_file('resque-web-service-defaults').with_content(/^HOST=0.0.0.0\nPORT=1234$/) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://jobs.example.com').with(
            'aliases'             => ['www.example.com', 'old.example.com'],
            'destination'         => 'http://0.0.0.0:1234/',
            'auth_openid_connect' => true
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
