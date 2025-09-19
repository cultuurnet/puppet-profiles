describe 'profiles::uitpas::api' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'in the production environment' do
        let(:environment) { 'production' }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with servername => uitpas.example.com and database_password => mypassword" do
            let(:params) { {
              'servername'        => 'uitpas.example.com',
              'database_password' => 'mypassword'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::api').with(
              'servername'                             =>'uitpas.example.com',
              'serveraliases'                          =>[],
              'database_password'                      =>'mypassword',
              'database_host'                          =>'127.0.0.1',
              'deployment'                             =>true,
              'initial_heap_size'                      =>nil,
              'maximum_heap_size'                      =>nil,
              'jmx'                                    =>true,
              'newrelic'                               =>false,
              'magda_cert_generation'                  =>false,
              'newrelic_license_key'                   =>'my_license_key',
              'portbase'                               =>4800,
              'service_status'                         =>'running',
              'settings'                               =>{}
            ) }

            it { is_expected.to contain_group('glassfish') }
            it { is_expected.to contain_user('glassfish') }
            it { is_expected.to not_contain_class('profiles::uitpas::api::magda') }

            it { is_expected.to contain_apt__source('publiq-tools') }

            it { is_expected.to contain_package('liquibase').with(
              'ensure' => 'present'
            ) }

            it { is_expected.to contain_package('mysql-connector-j').with(
              'ensure' => 'present'
            ) }

            it { is_expected.to contain_class('profiles::apache') }
            it { is_expected.to contain_class('profiles::java') }
            it { is_expected.to contain_class('profiles::glassfish') }
            it { is_expected.to contain_class('profiles::mysql::server') }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://uitpas.example.com').with(
              'destination' => 'http://127.0.0.1:4880/uitid/rest/',
              'aliases'     => []
            ) }

            it { is_expected.to contain_mysql_database('uitpas_api').with(
              'charset' => 'utf8mb4',
              'collate' => 'utf8mb4_unicode_ci'
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('uitpas_api@uitpas_api').with(
              'password' => 'mypassword',
              'remote'   => false
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('etl@uitpas_api').with(
              'password' => 'my_etl_password',
              'remote'   => false,
              'readonly' => true
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('2ndline_ro@uitpas_api').with(
              'password' => 'my_2ndline_ro_password',
              'remote'   => false,
              'readonly' => true
            ) }

            it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').with(
              'ensure'              => 'present',
              'user'                => 'glassfish',
              'passwordfile'        => '/home/glassfish/asadmin.pass',
              'portbase'            => '4800',
              'resourcetype'        => 'javax.sql.DataSource',
              'dsclassname'         => 'com.mysql.cj.jdbc.MysqlDataSource',
              'properties'          => {
                                         'serverName'        => '127.0.0.1',
                                         'portNumber'        => '3306',
                                         'databaseName'      => 'uitpas_api',
                                         'User'              => 'uitpas_api',
                                         'Password'          => 'mypassword',
                                         'URL'               => 'jdbc:mysql://127.0.0.1:3306/uitpas_api',
                                         'driverClass'       => 'com.mysql.cj.jdbc.Driver',
                                         'characterEncoding' => 'UTF-8',
                                         'useUnicode'        => true,
                                         'useSSL'            => false
                                       }
            )}

            it { is_expected.to contain_jdbcresource('jdbc/cultuurnet_uitpas').with(
              'ensure'         => 'present',
              'portbase'       => '4800',
              'user'           => 'glassfish',
              'passwordfile'   => '/home/glassfish/asadmin.pass',
              'connectionpool' => 'mysql_uitpas_api_j2eePool'
            ) }

            it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').with(
              'ensure'       => 'present',
              'value'        => 'X-Forwarded-Proto',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '4800'
            ) }

            it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').with(
              'ensure'       => 'present',
              'value'        => '32',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '4800'
            ) }

            it { is_expected.to contain_jvmoption('Clear domain uitpas default truststore').with(
              'ensure'       => 'absent',
              'option'       => '-Djavax.net.ssl.trustStore=\$\{com.sun.aas.instanceRoot\}/config/cacerts.jks',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '4800'
            ) }

            it { is_expected.to contain_jvmoption('Domain uitpas truststore').with(
              'ensure'       => 'present',
              'option'       => '-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '4800'
            ) }

            it { is_expected.to contain_jvmoption('Domain uitpas timezone').with(
              'ensure'       => 'present',
              'option'       => '-Duser.timezone=CET',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '4800'
            ) }

            it { is_expected.to contain_profiles__glassfish__domain('uitpas').with(
              'portbase'             => '4800',
              'initial_heap_size'    => nil,
              'maximum_heap_size'    => nil,
              'jmx'                  => true,
              'newrelic'             => false,
              'newrelic_license_key' => 'my_license_key',
              'newrelic_app_name'    => 'uitpas-api-production',
              'service_status'       => 'running'
            ) }

            it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitpas') }

            it { is_expected.to contain_service('uitpas').with(
              'enable'    => true,
              'ensure'    => 'running',
              'hasstatus' => true
            ) }

            it { is_expected.to contain_file('Domain uitpas mysql-connector-j').with(
              'ensure' => 'file',
              'path'   => '/opt/payara/glassfish/lib/mysql-connector-j.jar',
              'source' => '/usr/share/java/mysql-connector-j.jar'
            ) }

            it { is_expected.to contain_class('profiles::uitpas::api::deployment').with(
              'database_password' => 'mypassword',
              'database_host'     => '127.0.0.1'
            ) }

            it { is_expected.to contain_class('profiles::uitpas::api::cron').with(
              'portbase' => 4800
            ) }

            it { is_expected.to contain_package('liquibase').that_requires('Apt::Source[publiq-tools]') }
            it { is_expected.to contain_package('mysql-connector-j').that_requires('Apt::Source[publiq-tools]') }
            it { is_expected.to contain_package('liquibase').that_comes_before('Class[profiles::uitpas::api::deployment]') }
            it { is_expected.to contain_package('mysql-connector-j').that_comes_before('Class[profiles::uitpas::api::deployment]') }
            it { is_expected.to contain_class('profiles::mysql::server').that_comes_before('Mysql_database[uitpas_api]') }
            it { is_expected.to contain_profiles__mysql__app_user('uitpas_api@uitpas_api').that_requires('Mysql_database[uitpas_api]') }
            it { is_expected.to contain_profiles__mysql__app_user('uitpas_api@uitpas_api').that_comes_before('Class[profiles::uitpas::api::deployment]') }
            it { is_expected.to contain_profiles__mysql__app_user('etl@uitpas_api').that_requires('Mysql_database[uitpas_api]') }
            it { is_expected.to contain_profiles__mysql__app_user('2ndline_ro@uitpas_api').that_requires('Mysql_database[uitpas_api]') }
            it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').that_requires('Profiles::Glassfish::Domain[uitpas]') }
            it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').that_requires('Profiles::Mysql::App_user[uitpas_api@uitpas_api]') }
            it { is_expected.to contain_jdbcresource('jdbc/cultuurnet_uitpas').that_requires('Jdbcconnectionpool[mysql_uitpas_api_j2eePool]') }
            it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').that_requires('Profiles::Glassfish::Domain[uitpas]') }
            it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').that_notifies('Service[uitpas]') }
            it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').that_requires('Profiles::Glassfish::Domain[uitpas]') }
            it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').that_notifies('Service[uitpas]') }
            it { is_expected.to contain_jvmoption('Clear domain uitpas default truststore').that_requires('Profiles::Glassfish::Domain[uitpas]') }
            it { is_expected.to contain_jvmoption('Clear domain uitpas default truststore').that_notifies('Service[uitpas]') }
            it { is_expected.to contain_jvmoption('Domain uitpas truststore').that_requires('Profiles::Glassfish::Domain[uitpas]') }
            it { is_expected.to contain_jvmoption('Domain uitpas truststore').that_notifies('Service[uitpas]') }
            it { is_expected.to contain_jvmoption('Domain uitpas timezone').that_requires('Profiles::Glassfish::Domain[uitpas]') }
            it { is_expected.to contain_jvmoption('Domain uitpas timezone').that_notifies('Service[uitpas]') }
            it { is_expected.to contain_profiles__glassfish__domain('uitpas').that_requires('Class[profiles::glassfish]') }
            it { is_expected.to contain_profiles__glassfish__domain('uitpas').that_notifies('Service[uitpas]') }
            it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitpas').that_requires('Profiles::Glassfish::Domain[uitpas]') }
            it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitpas').that_comes_before('Service[uitpas]') }
            it { is_expected.to contain_file('Domain uitpas mysql-connector-j').that_requires('Package[mysql-connector-j]') }
            it { is_expected.to contain_file('Domain uitpas mysql-connector-j').that_comes_before('Profiles::Glassfish::Domain[uitpas]') }
            it { is_expected.to contain_file('Domain uitpas mysql-connector-j').that_comes_before('Class[profiles::uitpas::api::deployment]') }
            it { is_expected.to contain_class('profiles::uitpas::api::deployment').that_requires('Class[profiles::glassfish]') }
            it { is_expected.to contain_class('profiles::uitpas::api::deployment').that_notifies('Service[uitpas]') }
            it { is_expected.to contain_class('profiles::uitpas::api::cron').that_requires('Class[profiles::uitpas::api::deployment]') }
          end

          context "with servername => myserver.example.com, magda_cert_generation => true, serveraliases => foobar.example.com, database_password => secret, database_host => db.example.com, initial_heap_size => 1024m, maximum_heap_size => 1536m, jmx => false, newrelic => true, portbase => 14800 and settings => { 'foo' => 'bar', 'baz' => 'test' }" do
            let(:params) { {
              'servername'            => 'myserver.example.com',
              'serveraliases'         => 'foobar.example.com',
              'database_password'     => 'secret',
              'database_host'         => 'db.example.com',
              'initial_heap_size'     => '1024m',
              'magda_cert_generation' => true,
              'maximum_heap_size'     => '1536m',
              'jmx'                   => false,
              'newrelic'              => true,
              'portbase'              => 14800,
              'settings'              => { 'foo' => 'bar', 'baz' => 'test' }
            } }

            it { is_expected.not_to contain_class('profiles::mysql::server') }
            it { is_expected.to contain_class('profiles::uitpas::api::magda') }
            it { is_expected.to contain_class('profiles::mysql::remote_server').with(
              'host' => 'db.example.com'
            ) }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://myserver.example.com').with(
              'destination' => 'http://127.0.0.1:14880/uitid/rest/',
              'aliases'     => 'foobar.example.com'
            ) }

            it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').with(
              'ensure'       => 'present',
              'value'        => 'X-Forwarded-Proto',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '14800'
            ) }

            it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').with(
              'ensure'       => 'present',
              'value'        => '32',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '14800'
            ) }

            it { is_expected.to contain_systemproperty('foo').with(
              'ensure'         => 'present',
              'value'          => 'bar',
              'portbase'       => '14800',
              'user'           => 'glassfish',
              'passwordfile'   => '/home/glassfish/asadmin.pass',
            ) }

            it { is_expected.to contain_systemproperty('baz').with(
              'ensure'         => 'present',
              'value'          => 'test',
              'portbase'       => '14800',
              'user'           => 'glassfish',
              'passwordfile'   => '/home/glassfish/asadmin.pass',
            ) }

            it { is_expected.to contain_profiles__glassfish__domain('uitpas').with(
              'initial_heap_size'    => '1024m',
              'maximum_heap_size'    => '1536m',
              'jmx'                  => false,
              'newrelic'             => true,
              'newrelic_license_key' => 'my_license_key',
              'portbase'             => '14800'
            ) }

            it { is_expected.to contain_systemproperty('foo').that_requires('Profiles::Glassfish::Domain[uitpas]') }
            it { is_expected.to contain_systemproperty('foo').that_notifies('Service[uitpas]') }
            it { is_expected.to contain_systemproperty('baz').that_requires('Profiles::Glassfish::Domain[uitpas]') }
            it { is_expected.to contain_systemproperty('baz').that_notifies('Service[uitpas]') }

            context "with fact mysqld_version => 8.0.33" do
              let(:facts) { facts.merge( { 'mysqld_version' => '8.0.33' } ) }

              it { is_expected.to contain_mysql_database('uitpas_api').with(
                'charset' => 'utf8mb4',
                'collate' => 'utf8mb4_unicode_ci'
              ) }

              it { is_expected.to contain_profiles__mysql__app_user('uitpas_api@uitpas_api').with(
                'password' => 'secret',
                'remote'   => true
              ) }

              it { is_expected.to contain_profiles__mysql__app_user('etl@uitpas_api').with(
                'password' => 'my_etl_password',
                'remote'   => true,
                'readonly' => true
              ) }

              it { is_expected.to contain_profiles__mysql__app_user('2ndline_ro@uitpas_api').with(
                'password' => 'my_2ndline_ro_password',
                'remote'   => true,
                'readonly' => true
              ) }

              it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').with(
                'ensure'              => 'present',
                'user'                => 'glassfish',
                'passwordfile'        => '/home/glassfish/asadmin.pass',
                'portbase'            => '14800',
                'resourcetype'        => 'javax.sql.DataSource',
                'dsclassname'         => 'com.mysql.cj.jdbc.MysqlDataSource',
                'properties'          => {
                                           'serverName'        => 'db.example.com',
                                           'portNumber'        => '3306',
                                           'databaseName'      => 'uitpas_api',
                                           'User'              => 'uitpas_api',
                                           'Password'          => 'secret',
                                           'URL'               => 'jdbc:mysql://db.example.com:3306/uitpas_api',
                                           'driverClass'       => 'com.mysql.cj.jdbc.Driver',
                                           'characterEncoding' => 'UTF-8',
                                           'useUnicode'        => true,
                                           'useSSL'            => false
                                         }
              )}

              it { is_expected.to contain_jdbcresource('jdbc/cultuurnet_uitpas').with(
                'ensure'         => 'present',
                'portbase'       => '14800',
                'user'           => 'glassfish',
                'passwordfile'   => '/home/glassfish/asadmin.pass',
                'connectionpool' => 'mysql_uitpas_api_j2eePool'
              ) }

              it { is_expected.to contain_class('profiles::uitpas::api::deployment').with(
                'database_password' => 'secret',
                'database_host'     => 'db.example.com',
                'portbase'          => 14800
              ) }

              it { is_expected.to contain_class('profiles::uitpas::api::cron').with(
                'portbase' => 14800
              ) }
            end

            context "without extra facts" do
              let(:facts) { facts }

              it { is_expected.not_to contain_mysql_database('uitpas_api') }
              it { is_expected.not_to contain_profiles__mysql__app_user('uitpas_api@uitpas_api') }
              it { is_expected.not_to contain_profiles__mysql__app_user('etl@uitpas_api') }
              it { is_expected.not_to contain_profiles__mysql__app_user('2ndline_ro@uitpas_api') }
              it { is_expected.not_to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool') }
              it { is_expected.not_to contain_jdbcresource('jdbc/cultuurnet_uitpas') }
              it { is_expected.not_to contain_class('profiles::uitpas::api::deployment') }
            end
          end
        end

        context "with servername => bonkers.example.com, serveraliases => [dizzee.example.com, rascal.example.com], database_password => mysecret and deployment => false" do
          let(:params) { {
            'servername'        => 'bonkers.example.com',
            'serveraliases'     => ['dizzee.example.com', 'rascal.example.com'],
            'database_password' => 'mysecret',
            'deployment'        => false
          } }

          context 'with hieradata' do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bonkers.example.com').with(
              'destination' => 'http://127.0.0.1:4880/uitid/rest/',
              'aliases'     => ['dizzee.example.com', 'rascal.example.com']
            ) }

            it { is_expected.not_to contain_class('profiles::uitpas::api::deployment') }
            it { is_expected.not_to contain_class('profiles::uitpas::api::cron') }
          end
        end
      end

      context 'without hieradata' do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_password'/) }
      end

      context 'in the testing environment' do
        let(:environment) { 'testing' }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with servername => server.example.com, database_password => foo, newrelic => true, newrelic_license_key => bar and service_status => stopped" do
            let(:params) { {
              'servername'            => 'server.example.com',
              'database_password'     => 'foo',
              'newrelic'              => true,
              'magda_cert_generation' => false,
              'newrelic_license_key'  => 'bar',
              'service_status'        => 'stopped'
            } }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://server.example.com').with(
              'destination' => 'http://127.0.0.1:4880/uitid/rest/',
              'aliases'     => []
            ) }

            it { is_expected.to contain_profiles__glassfish__domain('uitpas').with(
              'initial_heap_size'    => nil,
              'maximum_heap_size'    => nil,
              'jmx'                  => true,
              'newrelic'             => true,
              'newrelic_app_name'    => 'uitpas-api-testing',
              'newrelic_license_key' => 'bar',
              'portbase'             => '4800',
              'service_status'       => 'stopped'
            ) }

            it { is_expected.to contain_service('uitpas').with(
              'enable'    => false,
              'ensure'    => 'stopped',
              'hasstatus' => true
            ) }
          end
        end
      end
    end
  end
end
