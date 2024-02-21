describe 'profiles::puppet::puppetdb' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on host aaa.example.com" do
        let(:node) { 'aaa.example.com' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::puppet::puppetdb').with(
            'version'           => 'installed',
            'certname'          => 'aaa.example.com',
            'initial_heap_size' => nil,
            'maximum_heap_size' => nil,
            'service_status'    => 'running'
          ) }

          it { is_expected.to contain_group('puppetdb') }
          it { is_expected.to contain_user('puppetdb') }

          it { is_expected.to contain_apt__source('puppet') }
          it { is_expected.to contain_firewall('300 accept puppetdb HTTPS traffic') }

          it { is_expected.to contain_class('profiles::java') }

          it { is_expected.to contain_class('profiles::puppet::puppetdb::certificate').with(
            'certname' => 'aaa.example.com'
          ) }

          it { is_expected.to contain_class('puppetdb::globals').with(
            'version' => 'installed'
          ) }

          it { is_expected.to contain_class('puppetdb::database::postgresql').with(
            'manage_package_repo' => false,
            'postgres_version'    => '12',
            'listen_addresses'    => '127.0.0.1'
          ) }

          it { is_expected.to contain_class('puppetdb::server').with(
            'database_host'           => '127.0.0.1',
            'puppetdb_service_status' => 'running',
            'manage_firewall'         => false,
            'java_args'               => {},
            'ssl_deploy_certs'        => false,
            'ssl_set_cert_paths'      => true
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetdb::certificate').that_notifies('Class[puppetdb::server]') }

          it { is_expected.to contain_class('puppetdb::database::postgresql').that_requires('Group[postgres]') }
          it { is_expected.to contain_class('puppetdb::database::postgresql').that_requires('User[postgres]') }

          it { is_expected.to contain_class('puppetdb::database::postgresql').that_requires('Class[puppetdb::globals]') }

          it { is_expected.to contain_class('puppetdb::server').that_requires('Group[puppetdb]') }
          it { is_expected.to contain_class('puppetdb::server').that_requires('User[puppetdb]') }
          it { is_expected.to contain_class('puppetdb::server').that_requires('Apt::Source[puppet]') }

          it { is_expected.to contain_class('puppetdb::server').that_requires('Class[puppetdb::globals]') }
          it { is_expected.to contain_class('puppetdb::server').that_requires('Class[profiles::java]') }
          it { is_expected.to contain_class('puppetdb::server').that_requires('Class[puppetdb::database::postgresql]') }
        end

        context "with version => 7.2.3, certname => puppetdb.example.com, initial_heap_size => 512m, maximum_heap_size => 512m and service_status => stopped" do
          let(:params) { {
            'version'           => '7.2.3',
            'certname'          => 'puppetdb.example.com',
            'initial_heap_size' => '512m',
            'maximum_heap_size' => '512m',
            'service_status'    => 'stopped'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::puppet::puppetdb::certificate').with(
            'certname' => 'puppetdb.example.com'
          ) }

          it { is_expected.to contain_class('puppetdb::globals').with(
            'version' => '7.2.3'
          ) }

          it { is_expected.to contain_class('puppetdb::server').with(
            'database_host'           => '127.0.0.1',
            'puppetdb_service_status' => 'stopped',
            'manage_firewall'         => false,
            'java_args'               => {
                                           '-Xms' => '512m',
                                           '-Xmx' => '512m'
                                         },
            'ssl_deploy_certs'        => false,
            'ssl_set_cert_paths'      => true
          ) }
        end
      end
    end
  end
end
