describe 'profiles::uitpas::api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with database_password => secret" do
        let(:params) { {
          'database_password' => 'secret'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitpas::api::deployment').with(
          'database_password' => 'secret',
          'database_host'     => '127.0.0.1',
          'version'           => 'latest',
          'repository'        => 'uitpas-api',
          'puppetdb_url'      => nil
        ) }

        it { is_expected.to contain_apt__source('uitpas-api') }
        it { is_expected.to contain_user('glassfish') }

        it { is_expected.to contain_package('uitpas-api').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_package('uitpas-db-mgmt').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_app('uitpas-api').with(
          'ensure'        => 'present',
          'portbase'      => '4800',
          'user'          => 'glassfish',
          'passwordfile'  => '/home/glassfish/asadmin.pass',
          'contextroot'   => 'uitid',
          'precompilejsp' => false,
          'source'        => '/opt/uitpas-api/uitpas-api.war'
        ) }

        it { is_expected.to contain_exec('uitpas_database_management').with(
          'command'     => "liquibase --driver=com.mysql.jdbc.Driver --classpath=/opt/uitpas-db-mgmt/uitpas-db-mgmt.jar:/usr/share/java/mysql-connector-j.jar --changeLogFile=migrations.xml --url='jdbc:mysql://127.0.0.1:3306/uitpas_api?useSSL=false' --username=uitpas_api --password=secret update",
          'path'        => ['/opt/liquibase', '/usr/local/bin', '/usr/bin', '/bin'],
          'refreshonly' => true,
          'logoutput'   => true
        ) }

        it { is_expected.to contain_package('uitpas-api').that_requires('Apt::Source[uitpas-api]') }
        it { is_expected.to contain_package('uitpas-api').that_notifies('App[uitpas-api]') }
        it { is_expected.to contain_package('uitpas-api').that_notifies('Profiles::Deployment::Versions[profiles::uitpas::api::deployment]') }
        it { is_expected.to contain_package('uitpas-db-mgmt').that_requires('Apt::Source[uitpas-api]') }
        it { is_expected.to contain_package('uitpas-db-mgmt').that_notifies('Exec[uitpas_database_management]') }
        it { is_expected.to contain_package('uitpas-db-mgmt').that_notifies('Profiles::Deployment::Versions[profiles::uitpas::api::deployment]') }
        it { is_expected.to contain_app('uitpas-api').that_requires('User[glassfish]') }
        it { is_expected.to contain_app('uitpas-api').that_requires('Exec[uitpas_database_management]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::api::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::api::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context "with database_password => mypass, database_host => mydb.example.com, version => 3.2.1 and repository => uitpas-api-alternative" do
        let(:params) { {
          'database_password' => 'mypass',
          'database_host'     => 'mydb.example.com',
          'version'           => '3.2.1',
          'repository'        => 'uitpas-api-alternative'
        } }

        context "with repository uitpas-api-alternative defined" do
          let(:pre_condition) { '@apt::source { "uitpas-api-alternative": location => "http://localhost", release => "focal", repos => "main" }' }

          it { is_expected.to contain_apt__source('uitpas-api-alternative') }

          it { is_expected.to contain_package('uitpas-api').with(
            'ensure' => '3.2.1'
          ) }

          it { is_expected.to contain_package('uitpas-db-mgmt').with(
            'ensure' => '3.2.1'
          ) }

          it { is_expected.to contain_exec('uitpas_database_management').with(
            'command'     => "liquibase --driver=com.mysql.jdbc.Driver --classpath=/opt/uitpas-db-mgmt/uitpas-db-mgmt.jar:/usr/share/java/mysql-connector-j.jar --changeLogFile=migrations.xml --url='jdbc:mysql://mydb.example.com:3306/uitpas_api?useSSL=false' --username=uitpas_api --password=mypass update",
            'path'        => ['/opt/liquibase', '/usr/local/bin', '/usr/bin', '/bin'],
            'refreshonly' => true,
            'logoutput'   => true
          ) }

          it { is_expected.to contain_package('uitpas-api').that_requires('Apt::Source[uitpas-api-alternative]') }
          it { is_expected.to contain_package('uitpas-db-mgmt').that_requires('Apt::Source[uitpas-api-alternative]') }
        end
      end
    end
  end
end
