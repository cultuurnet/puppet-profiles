describe 'profiles::php' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'on node aaa.example.com' do
        let(:node) { 'aaa.example.com' }

        context 'without parameters' do
          let(:params) { {} }

          context 'with hieradata' do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::php').with(
              'version'                  => '7.4',
              'extensions'               => {},
              'settings'                 => {},
              'composer_default_version' => nil,
              'fpm'                      => true,
              'fpm_socket_type'          => 'tcp',
              'fpm_service_status'       => 'running',
              'fpm_restart_on_change'    => false,
              'fpm_settings'             => {},
              'newrelic'                 => false,
              'newrelic_app_name'        => 'aaa.example.com',
              'newrelic_license_key'     => 'my_license_key'
            ) }

            it { is_expected.to contain_apt__source('php') }
            it { is_expected.not_to contain_apt__source('publiq-tools') }

            it { is_expected.to contain_class('php::globals').with(
              'php_version' => '7.4',
              'config_root' => '/etc/php/7.4'
            ) }

            it { is_expected.to contain_class('php').with(
              'manage_repos'                 => false,
              'composer'                     => false,
              'dev'                          => false,
              'pear'                         => false,
              'fpm'                          => true,
              'settings'                     => {
                                                  'openssl/openssl.cafile' => '/etc/ssl/certs/ca-certificates.crt'
                                                },
              'extensions'                   => {
                                                  'apcu'     => {},
                                                  'bcmath'   => {},
                                                  'curl'     => {},
                                                  'gd'       => {},
                                                  'intl'     => {},
                                                  'json'     => {},
                                                  'mbstring' => {},
                                                  'mysql'    => {},
                                                  'opcache'  => { 'zend' => true },
                                                  'readline' => {},
                                                  'redis'    => {},
                                                  'tidy'     => {},
                                                  'xml'      => {},
                                                  'zip'      => {}
                                                },
              'fpm_service_ensure'           => 'running',
              'fpm_service_enable'           => true,
              'fpm_pools'                    => { 'www' => {
                                                             'catch_workers_output'      => 'no',
                                                             'listen'                    => '/run/php/php7.4-fpm.sock',
                                                             'listen_backlog'            => -1,
                                                             'pm'                        => 'dynamic',
                                                             'pm_max_children'           => 50,
                                                             'pm_max_requests'           => 0,
                                                             'pm_max_spare_servers'      => 35,
                                                             'pm_min_spare_servers'      => 5,
                                                             'pm_start_servers'          => 5,
                                                             'request_terminate_timeout' => 0
                                                           }
                                                },
              'fpm_global_pool_settings'     => {
                                                  'listen_owner' => 'www-data',
                                                  'listen_group' => 'www-data',
                                                  'listen'       => '127.0.0.1:9000'
                                                },
              'reload_fpm_on_config_changes' => true
            ) }

            it { is_expected.to contain_file('php-fpm service').with(
              'ensure' => 'link',
              'path'   => '/etc/systemd/system/php-fpm.service',
              'target' => '/lib/systemd/system/php7.4-fpm.service'
            ) }

            it { is_expected.to contain_systemd__daemon_reload('php-fpm') }

            it { is_expected.to contain_package('composer').with(
              'ensure' => 'absent'
            ) }

            it { is_expected.not_to contain_package('composer1').with(
              'ensure' => 'present'
            ) }

            it { is_expected.not_to contain_package('composer2').with(
              'ensure' => 'present'
            ) }

            it { is_expected.not_to contain_alternatives('composer').with(
              'path' => '/usr/bin/composer2'
            ) }

            it { is_expected.not_to contain_package('git').with(
              'ensure' => 'present'
            ) }

            it { is_expected.not_to contain_class('profiles::newrelic::php') }

            it { is_expected.to contain_class('php::globals').that_requires('Apt::Source[php]') }
            it { is_expected.to contain_class('php').that_requires('Class[php::globals]') }
            it { is_expected.to contain_file('php-fpm service').that_notifies('Systemd::Daemon_reload[php-fpm]') }
          end

          context 'without hieradata' do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            it { is_expected.to contain_class('profiles::php').with(
              'version'                  => '7.4',
              'extensions'               => {},
              'settings'                 => {},
              'composer_default_version' => nil,
              'fpm'                      => true,
              'fpm_socket_type'          => 'unix',
              'fpm_service_status'       => 'running',
              'fpm_settings'             => {},
              'newrelic'                 => false,
              'newrelic_app_name'        => 'aaa.example.com',
              'newrelic_license_key'     => nil
            ) }
          end
        end

        context 'with version => 8.0, extensions => { mbstring => {}, mysql => { so_name => mysqlnd }, mongodb => {} }, settings => { PHP/upload_max_filesize => 22M, PHP/post_max_size => 24M }, fpm => false and composer_default_version => 2' do
          let(:params) { {
            'version'                  => '8.0',
            'extensions'               => {
                                            'mbstring' => {},
                                            'mysql'    => { 'so_name' => 'mysqlnd' },
                                            'mongodb'  => {}
                                          },
            'settings'                 => {
                                            'PHP/upload_max_filesize' => '22M',
                                            'PHP/post_max_size'       => '24M'
                                          },
            'fpm'                      => false,
            'composer_default_version' => 2
          } }

          it { is_expected.to contain_class('php::globals').with(
            'php_version' => '8.0',
            'config_root' => '/etc/php/8.0'
          ) }

          it { is_expected.to contain_class('php').with(
            'manage_repos'             => false,
            'composer'                 => false,
            'dev'                      => false,
            'pear'                     => false,
            'settings'                 => {
                                            'openssl/openssl.cafile'  => '/etc/ssl/certs/ca-certificates.crt',
                                            'PHP/upload_max_filesize' => '22M',
                                            'PHP/post_max_size'       => '24M'
                                          },
            'extensions'               => {
                                            'apcu'     => {},
                                            'bcmath'   => {},
                                            'curl'     => {},
                                            'gd'       => {},
                                            'intl'     => {},
                                            'mbstring' => {},
                                            'mongodb'  => {},
                                            'mysql'    => { 'so_name' => 'mysqlnd' },
                                            'opcache'  => { 'zend' => true },
                                            'readline' => {},
                                            'redis'    => {},
                                            'tidy'     => {},
                                            'xml'      => {},
                                            'zip'      => {}
                                          },
            'fpm'                      => false
          ) }

          it { is_expected.not_to contain_file('php-fpm service') }

          it { is_expected.not_to contain_systemd__daemon_reload('php-fpm') }

          it { is_expected.to contain_apt__source('publiq-tools') }

          it { is_expected.to contain_package('composer1').with(
            'ensure' => 'present'
          ) }

          it { is_expected.to contain_package('composer2').with(
            'ensure' => 'present'
          ) }

          it { is_expected.to contain_alternatives('composer').with(
            'path' => '/usr/bin/composer2'
          ) }

          it { is_expected.not_to contain_class('profiles::newrelic::php') }

          it { is_expected.to contain_package('composer1').that_requires('Class[php]') }
          it { is_expected.to contain_package('composer2').that_requires('Class[php]') }
          it { is_expected.to contain_alternatives('composer').that_requires(['Package[composer1]', 'Package[composer2]']) }
        end
      end

      context 'on node bbb.example.com' do
        let(:node) { 'bbb.example.com' }

        context 'with version => 8.2, composer_default_version => 1, newrelic => true, fpm_socket_type => unix, fpm_restart_on_change => true, fpm_settings => { pm_max_children => 100, pm_max_requests => 5000 } and fpm_service_status => stopped' do
          let(:params) { {
            'version'                  => '8.2',
            'composer_default_version' => 1,
            'fpm_socket_type'          => 'unix',
            'fpm_service_status'       => 'stopped',
            'fpm_restart_on_change'    => true,
            'fpm_settings'             => {
                                            'pm_max_children' => 100,
                                            'pm_max_requests' => 5000
                                          },
            'newrelic'                 => true
          } }

          context 'with hieradata' do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to contain_class('profiles::php').with(
              'newrelic_app_name' => 'bbb.example.com'
            ) }

            it { is_expected.to contain_apt__source('publiq-tools') }

            it { is_expected.to contain_package('composer1').with(
              'ensure' => 'present'
            ) }

            it { is_expected.to contain_package('composer2').with(
              'ensure' => 'present'
            ) }

            it { is_expected.to contain_alternatives('composer').with(
              'path' => '/usr/bin/composer1'
            ) }

            it { is_expected.to contain_class('php').with(
              'manage_repos'                 => false,
              'composer'                     => false,
              'dev'                          => false,
              'pear'                         => false,
              'settings'                     => {
                                                  'openssl/openssl.cafile' => '/etc/ssl/certs/ca-certificates.crt'
                                                },
              'extensions'                   => {
                                                  'apcu'     => {},
                                                  'bcmath'   => {},
                                                  'curl'     => {},
                                                  'gd'       => {},
                                                  'intl'     => {},
                                                  'mbstring' => {},
                                                  'mysql'    => {},
                                                  'opcache'  => { 'zend' => true },
                                                  'readline' => {},
                                                  'redis'    => {},
                                                  'tidy'     => {},
                                                  'xml'      => {},
                                                  'zip'      => {}
                                                },
              'fpm'                          => true,
              'fpm_service_ensure'           => 'stopped',
              'fpm_service_enable'           => false,
              'fpm_pools'                    => { 'www' => {
                                                             'catch_workers_output'      => 'no',
                                                             'listen'                    => '/run/php/php7.4-fpm.sock',
                                                             'listen_backlog'            => -1,
                                                             'pm'                        => 'dynamic',
                                                             'pm_max_children'           => 100,
                                                             'pm_max_requests'           => 5000,
                                                             'pm_max_spare_servers'      => 35,
                                                             'pm_min_spare_servers'      => 5,
                                                             'pm_start_servers'          => 5,
                                                             'request_terminate_timeout' => 0
                                                           }
                                                },
              'fpm_global_pool_settings'     => {
                                                  'listen_owner' => 'www-data',
                                                  'listen_group' => 'www-data',
                                                  'listen'       => '/run/php/php8.2-fpm.sock'
                                                },
              'reload_fpm_on_config_changes' => false
            ) }

            it { is_expected.to contain_class('php::globals').with(
              'php_version' => '8.2',
              'config_root' => '/etc/php/8.2'
            ) }

            it { is_expected.to contain_file('php-fpm service').with(
              'ensure' => 'link',
              'path'   => '/etc/systemd/system/php-fpm.service',
              'target' => '/lib/systemd/system/php8.2-fpm.service'
            ) }

            it { is_expected.to contain_systemd__daemon_reload('php-fpm') }

            it { is_expected.to contain_class('profiles::newrelic::php').with(
              'app_name'    => 'bbb.example.com',
              'license_key' => 'my_license_key'
            ) }
          end

          context 'without hieradata' do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'newrelic_license_key'/) }
          end
        end
      end
    end
  end
end
