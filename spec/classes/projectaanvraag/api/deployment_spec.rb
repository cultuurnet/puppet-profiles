describe 'profiles::projectaanvraag::api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => appconfig/projectaanvraag/api/config.yml, integration_types_source => appconfig/projectaanvraag/api/integration_types.yml and user_roles_source => appconfig/projectaanvraag/api/user_roles.yml" do
        let(:params) { {
          'config_source'            => 'appconfig/projectaanvraag/api/config.yml',
          'integration_types_source' => 'appconfig/projectaanvraag/api/integration_types.yml',
          'user_roles_source'        => 'appconfig/projectaanvraag/api/user_roles.yml'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::projectaanvraag::api::deployment').with(
            'config_source'            => 'appconfig/projectaanvraag/api/config.yml',
            'integration_types_source' => 'appconfig/projectaanvraag/api/integration_types.yml',
            'user_roles_source'        => 'appconfig/projectaanvraag/api/user_roles.yml',
            'version'                  => 'latest',
            'repository'               => 'projectaanvraag-api',
            'database_name'            => 'projectaanvraag',
            'puppetdb_url'             => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_apt__source('projectaanvraag-api') }
          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_package('projectaanvraag-api').with(
            'ensure' => 'latest'
          ) }

          it { is_expected.to contain_file('projectaanvraag-api-config').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/var/www/projectaanvraag-api/config.yml',
            'content' => "projectaanvraag-api config\n"
          ) }

          it { is_expected.to contain_file('projectaanvraag-api-integration-types').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/var/www/projectaanvraag-api/integration_types.yml',
            'content' => "projectaanvraag-api integration-types\n"
          ) }

          it { is_expected.to contain_file('projectaanvraag-api-user-roles').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/var/www/projectaanvraag-api/user_roles.yml',
            'content' => "projectaanvraag-api user-roles\n"
          ) }

          it { is_expected.to contain_exec('projectaanvraag-api-cache-clear').with(
            'command'     => 'bin/console projectaanvraag:cache-clear',
            'cwd'         => '/var/www/projectaanvraag-api',
            'path'        => ['/usr/bin', '/bin', '/var/www/projectaanvraag-api'],
            'logoutput'   => 'on_failure',
            'refreshonly' => true
          ) }

          it { is_expected.to contain_exec('projectaanvraag-api-db-install').with(
            'command'   => 'bin/console orm:schema-tool:create',
            'cwd'       => '/var/www/projectaanvraag-api',
            'path'      => ['/usr/bin', '/bin', '/var/www/projectaanvraag-api'],
            'logoutput' => 'on_failure',
            'onlyif'    => "test 0 -eq $(mysql --defaults-extra-file=/root/.my.cnf -s --skip-column-names -e 'select count(table_name) from information_schema.tables where table_schema = \"projectaanvraag\";')",
          ) }

          it { is_expected.to contain_exec('projectaanvraag-api-clear-metadata-cache').with(
            'command'     => 'bin/console orm:clear-cache:metadata',
            'cwd'         => '/var/www/projectaanvraag-api',
            'path'        => ['/usr/bin', '/bin', '/var/www/projectaanvraag-api'],
            'logoutput'   => 'on_failure',
            'refreshonly' => true
          ) }

          it { is_expected.to contain_exec('projectaanvraag-api-db-migrate').with(
            'command'     => 'bin/console orm:schema-tool:update --force',
            'cwd'         => '/var/www/projectaanvraag-api',
            'path'        => ['/usr/bin', '/bin', '/var/www/projectaanvraag-api'],
            'logoutput'   => 'on_failure',
            'refreshonly' => true
          ) }

          it { is_expected.to contain_profiles__php__fpm_service_alias('projectaanvraag-api') }

          it { is_expected.to contain_class('profiles::projectaanvraag::api::logrotate').with(
            'basedir' => '/var/www/projectaanvraag-api'
          ) }

          it { is_expected.to contain_service('projectaanvraag-api').with(
            'hasstatus'  => true,
            'hasrestart' => true,
            'restart'    => '/usr/bin/systemctl reload projectaanvraag-api'
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::projectaanvraag::api::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_package('projectaanvraag-api').that_notifies('Profiles::Deployment::Versions[profiles::projectaanvraag::api::deployment]') }
          it { is_expected.to contain_package('projectaanvraag-api').that_requires('Apt::Source[projectaanvraag-api]') }
          it { is_expected.to contain_package('projectaanvraag-api').that_notifies('Service[projectaanvraag-api]') }
          it { is_expected.to contain_file('projectaanvraag-api-config').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('projectaanvraag-api-config').that_requires('User[www-data]') }
          it { is_expected.to contain_file('projectaanvraag-api-config').that_requires('Package[projectaanvraag-api]') }
          it { is_expected.to contain_file('projectaanvraag-api-config').that_notifies('Service[projectaanvraag-api]') }
          it { is_expected.to contain_file('projectaanvraag-api-integration-types').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('projectaanvraag-api-integration-types').that_requires('User[www-data]') }
          it { is_expected.to contain_file('projectaanvraag-api-integration-types').that_requires('Package[projectaanvraag-api]') }
          it { is_expected.to contain_file('projectaanvraag-api-integration-types').that_notifies('Service[projectaanvraag-api]') }
          it { is_expected.to contain_file('projectaanvraag-api-user-roles').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('projectaanvraag-api-user-roles').that_requires('User[www-data]') }
          it { is_expected.to contain_file('projectaanvraag-api-user-roles').that_requires('Package[projectaanvraag-api]') }
          it { is_expected.to contain_file('projectaanvraag-api-user-roles').that_notifies('Service[projectaanvraag-api]') }
          it { is_expected.to contain_exec('projectaanvraag-api-cache-clear').that_subscribes_to('File[projectaanvraag-api-config]') }
          it { is_expected.to contain_exec('projectaanvraag-api-cache-clear').that_subscribes_to('File[projectaanvraag-api-integration-types]') }
          it { is_expected.to contain_exec('projectaanvraag-api-cache-clear').that_subscribes_to('File[projectaanvraag-api-user-roles]') }
          it { is_expected.to contain_exec('projectaanvraag-api-cache-clear').that_subscribes_to('Package[projectaanvraag-api]') }
          it { is_expected.to contain_exec('projectaanvraag-api-db-install').that_subscribes_to('Package[projectaanvraag-api]') }
          it { is_expected.to contain_exec('projectaanvraag-api-clear-metadata-cache').that_requires('Exec[projectaanvraag-api-db-install]') }
          it { is_expected.to contain_exec('projectaanvraag-api-clear-metadata-cache').that_subscribes_to('Package[projectaanvraag-api]') }
          it { is_expected.to contain_exec('projectaanvraag-api-db-migrate').that_requires('Exec[projectaanvraag-api-clear-metadata-cache]') }
          it { is_expected.to contain_exec('projectaanvraag-api-db-migrate').that_subscribes_to('Package[projectaanvraag-api]') }
          it { is_expected.to contain_service('projectaanvraag-api').that_requires('Profiles::Php::Fpm_service_alias[projectaanvraag-api]') }
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::projectaanvraag::api::deployment').with(
            'puppetdb_url' => nil
          ) }
        end
      end

      context "with config_source => appconfig/projectaanvraag/api/myconfig.yml, integration_types_source => appconfig/projectaanvraag/api/my_integration_types.yml, appconfig/projectaanvraag/api/my_user_roles.yml, version => 1.2.3, repository => myrepo, database_name => mydb and puppetdb_url => http://puppetdb.example.com:8080" do
        let(:params) { {
          'config_source'            => 'appconfig/projectaanvraag/api/myconfig.yml',
          'integration_types_source' => 'appconfig/projectaanvraag/api/my_integration_types.yml',
          'user_roles_source'        => 'appconfig/projectaanvraag/api/my_user_roles.yml',
          'version'                  => '1.2.3',
          'repository'               => 'myrepo',
          'database_name'            => 'mydb',
          'puppetdb_url'             => 'http://puppetdb.example.com:8080'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'with repository myrepo defined' do
            let(:pre_condition) { [
              '@apt::source { "myrepo": location => "http://localhost", release => "focal", repos => "main" }',
            ] }

            it { is_expected.to contain_apt__source('myrepo') }

            it { is_expected.to contain_package('projectaanvraag-api').with(
              'ensure' => '1.2.3'
            ) }

            it { is_expected.to contain_file('projectaanvraag-api-config').with(
              'content' => ''
            ) }

            it { is_expected.to contain_file('projectaanvraag-api-integration-types').with(
              'content' => ''
            ) }

            it { is_expected.to contain_file('projectaanvraag-api-user-roles').with(
              'content' => ''
            ) }

            it { is_expected.to contain_exec('projectaanvraag-api-db-install').with(
              'command'   => 'bin/console orm:schema-tool:create',
              'cwd'       => '/var/www/projectaanvraag-api',
              'path'      => ['/usr/bin', '/bin', '/var/www/projectaanvraag-api'],
              'logoutput' => 'on_failure',
              'onlyif'    => "test 0 -eq $(mysql --defaults-extra-file=/root/.my.cnf -s --skip-column-names -e 'select count(table_name) from information_schema.tables where table_schema = \"mydb\";')",
            ) }

            it { is_expected.to contain_package('projectaanvraag-api').that_requires('Apt::Source[myrepo]') }

            it { is_expected.to contain_profiles__deployment__versions('profiles::projectaanvraag::api::deployment').with(
              'puppetdb_url' => 'http://puppetdb.example.com:8080'
            ) }
          end
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'integration_types_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'user_roles_source'/) }
      end
    end
  end
end
