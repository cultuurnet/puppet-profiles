describe 'profiles::puppet::puppetboard' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'on node node1.example.com' do
        let(:node) { 'node1.example.com' }

        context 'with servername => puppetboard.example.com' do
          let(:params) { {
            'servername' => 'puppetboard.example.com'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::apache') }

          it { is_expected.to contain_class('profiles::puppet::puppetboard').with(
            'servername'      => 'puppetboard.example.com',
            'serveraliases'   => [],
            'service_address' => '127.0.0.1',
            'service_port'    => 6000,
            'service_status'  => 'running'
          ) }

          it { is_expected.to contain_apt__source('publiq-tools') }
          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_service('puppetboard').with(
            'ensure'    => 'running',
            'hasstatus' => true,
            'enable'    => true
          ) }

          it { is_expected.to contain_class('puppetboard').with(
            'install_from'        => 'package',
            'package_name'        => 'puppetboard',
            'group'               => 'www-data',
            'user'                => 'www-data',
            'manage_group'        => false,
            'manage_user'         => false,
            'secret_key'          => 'a3Tl84mHAFP1DoOvMDESaXyXcUsC2cPu',
            'puppetdb_host'       => '127.0.0.1',
            'puppetdb_port'       => 8081,
            'puppetdb_ssl_verify' => false,
            'puppetdb_key'        => '/var/www/puppetboard/ssl/private.pem',
            'puppetdb_cert'       => '/var/www/puppetboard/ssl/public.pem',
            'enable_catalog'      => false,
            'enable_query'        => true,
            'default_environment' => 'production',
            'reports_count'       => 20,
            'settings_file'       => '/var/www/puppetboard/settings.py',
            'extra_settings'      => {}
          ) }

          it { is_expected.to contain_file('puppetboard service defaults').with(
            'ensure'  => 'file',
            'path'    => '/etc/default/puppetboard',
            'content' => "HOST=127.0.0.1\nPORT=6000"
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetboard::certificate').with(
            'certname' => 'puppetboard.example.com',
            'basedir'  => '/var/www/puppetboard'
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://puppetboard.example.com').with(
            'destination' => 'http://127.0.0.1:6000/',
            'aliases'     => []
          ) }

          it { is_expected.to contain_apt__source('publiq-tools').that_comes_before('Class[puppetboard]') }
          it { is_expected.to contain_group('www-data').that_comes_before('Class[puppetboard]') }
          it { is_expected.to contain_user('www-data').that_comes_before('Class[puppetboard]') }
          it { is_expected.to contain_service('puppetboard').that_subscribes_to('Class[puppetboard]') }
          it { is_expected.to contain_service('puppetboard').that_subscribes_to('File[puppetboard service defaults]') }
          it { is_expected.to contain_service('puppetboard').that_subscribes_to('Class[profiles::puppet::puppetboard::certificate]') }
        end

        context "with servername => mypb.example.com, serveraliases => pb.example.com, service_address => 127.0.1.1, service_port => 4000 and service_status => stopped " do
          let(:params) { {
            'servername'      => 'mypb.example.com',
            'serveraliases'  => 'pb.example.com',
            'service_address' => '127.0.1.1',
            'service_port'    => 4000,
            'service_status'  => 'stopped'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_service('puppetboard').with(
            'ensure'    => 'stopped',
            'hasstatus' => true,
            'enable'    => false
          ) }

          it { is_expected.to contain_file('puppetboard service defaults').with(
            'ensure'  => 'file',
            'path'    => '/etc/default/puppetboard',
            'content' => "HOST=127.0.1.1\nPORT=4000"
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetboard::certificate').with(
            'certname' => 'mypb.example.com',
            'basedir'  => '/var/www/puppetboard'
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://mypb.example.com').with(
            'destination' => 'http://127.0.1.1:4000/',
            'aliases'     => 'pb.example.com'
          ) }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
