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
              'manage_repos'             => false,
              'composer'                 => false,
              'dev'                      => false,
              'pear'                     => false,
              'fpm'                      => true,
              'settings'                 => {
                                              'openssl/openssl.cafile' => '/etc/ssl/certs/ca-certificates.crt'
                                            },
              'extensions'               => {
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
              'fpm_service_ensure'       => 'running',
              'fpm_service_enable'       => true,
              'fpm_pools'                => { 'www' => {} },
              'fpm_global_pool_settings' => {
                                              'listen_owner' => 'www-data',
                                              'listen_group' => 'www-data',
                                              'listen'       => '127.0.0.1:9000'
                                            }
            ) }

            it { is_expected.to contain_systemd__dropin_file('php-fpm service override.conf').with(
              'unit'     => 'php7.4-fpm.service',
              'filename' => 'override.conf',
              'content'  => "[Install]\nAlias=php-fpm.service"
            ) }

            it { is_expected.to contain_exec('re-enable php7.4-fpm').with(
              'command'     => 'systemctl reenable php7.4-fpm',
              'path'        => ['/usr/sbin', '/usr/bin'],
              'refreshonly' => true,
              'logoutput'   => 'on_failure'
            ) }

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

          it { is_expected.not_to contain_systemd__dropin_file('php-fpm service override.conf') }

          it { is_expected.not_to contain_exec('re-enable php8.0-fpm') }

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

        context 'with composer_default_version => 1, newrelic => true, fpm_socket_type => unix and fpm_service_status => stopped' do
          let(:params) { {
            'composer_default_version' => 1,
            'fpm_socket_type'          => 'unix',
            'fpm_service_status'       => 'stopped',
            'newrelic'                 => true
          } }

          context 'with hieradata' do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to contain_class('profiles::php').with(
              'newrelic_app_name' => 'bbb.example.com'
            ) }

            it { is_expected.to contain_systemd__dropin_file('php-fpm service override.conf').with(
              'unit'     => 'php7.4-fpm.service',
              'filename' => 'override.conf',
              'content'  => "[Install]\nAlias=php-fpm.service"
            ) }

            it { is_expected.not_to contain_exec('re-enable php7.4-fpm') }

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
              'manage_repos'             => false,
              'composer'                 => false,
              'dev'                      => false,
              'pear'                     => false,
              'settings'                 => {
                                              'openssl/openssl.cafile' => '/etc/ssl/certs/ca-certificates.crt'
                                            },
              'extensions'               => {
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
              'fpm'                      => true,
              'fpm_service_ensure'       => 'stopped',
              'fpm_service_enable'       => false,
              'fpm_pools'                => { 'www' => {} },
              'fpm_global_pool_settings' => {
                                              'listen_owner' => 'www-data',
                                              'listen_group' => 'www-data',
                                              'listen'       => '/var/run/php/php-fpm.sock'
                                            }
            ) }

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
