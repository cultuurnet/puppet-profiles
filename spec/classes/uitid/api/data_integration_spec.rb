describe 'profiles::uitid::api::data_integration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'on node node1.example.com' do
        let(:node) { 'node1.example.com' }

        context 'with database_name => barbaz' do
          let(:params) { {
            'database_name' => 'barbaz'
          } }

          context 'without extra parameters' do
            let(:params) { super() }

            context 'with hieradata' do
              let(:hiera_config) { 'spec/support/hiera/common.yaml' }

              it { is_expected.to compile.with_all_deps }

              it { is_expected.to contain_class('profiles::uitid::api::data_integration').with(
                'database_name' => 'barbaz',
                'database_host' => '127.0.0.1'
              ) }

              it { is_expected.to contain_class('profiles::data_integration') }

              it { is_expected.to have_profiles__mysql__app_user_resource_count(1) }

              it { is_expected.to contain_profiles__mysql__app_user('sling@barbaz').with(
                'user'     => 'sling',
                'database' => 'barbaz',
                'tables'   => ['EVENTS_DBLOG', 'MAILINGSUBSCRIBER', 'MAILINGSUBSCRIPTION', 'DALISERVICECONSUMER'],
                'readonly' => true,
                'remote'   => false,
                'password' => 'JUtWB3Gk5RJqErUePdGT'
              ) }

              it { is_expected.to contain_profiles__sling__connection('barbaz').with(
                'type'          => 'mysql',
                'configuration' => {
                                     'user'     => 'sling',
                                     'password' => 'JUtWB3Gk5RJqErUePdGT',
                                     'host'     => '127.0.0.1',
                                     'database' => 'barbaz'
                                   }
              ) }

              it { is_expected.to contain_file('parquetdump_to_gcs').with(
                'ensure' => 'file',
                'path'   => '/usr/local/bin/parquetdump_to_gcs',
                'mode'   => '0755'
              ) }


              it { is_expected.to contain_file('parquetdump_to_gcs').with_content(/^database_name=barbaz$/) }
              it { is_expected.to contain_file('parquetdump_to_gcs').with_content(/^source_table_names=\(EVENTS_DBLOG MAILINGSUBSCRIBER MAILINGSUBSCRIPTION DALISERVICECONSUMER\)$/) }

              it { is_expected.to contain_cron('parquetdump_to_gcs').with(
                'ensure'      => 'present',
                'command'     => '/usr/local/bin/parquetdump_to_gcs',
                'environment' => ['SHELL=/bin/bash', 'MAILTO=infra+cron@publiq.be'],
                'hour'        => 0,
                'minute'      => 15
              ) }

              it { is_expected.to contain_profiles__sling__connection('barbaz').that_requires('Profiles::Mysql::App_user[sling@barbaz]') }
              it { is_expected.to contain_file('parquetdump_to_gcs').that_requires('Profiles::Sling::Connection[barbaz]') }
              it { is_expected.to contain_cron('parquetdump_to_gcs').that_requires('File[parquetdump_to_gcs]') }
            end
          end

          context 'with database_host => foo.example.com and database_name => mydb' do
            let(:params) { super().merge({
              'database_host' => 'foo.example.com',
              'database_name' => 'mydb'
            }) }

            context 'with hieradata' do
              let(:hiera_config) { 'spec/support/hiera/common.yaml' }

              it { is_expected.to contain_profiles__mysql__app_user('sling@mydb').with(
                'user'     => 'sling',
                'database' => 'mydb',
                'tables'   => ['EVENTS_DBLOG', 'MAILINGSUBSCRIBER', 'MAILINGSUBSCRIPTION', 'DALISERVICECONSUMER'],
                'readonly' => true,
                'remote'   => true,
                'password' => 'BRQ4p5tKpAun8iCX5PRQ'
              ) }

              it { is_expected.to contain_profiles__sling__connection('mydb').with(
                'type'          => 'mysql',
                'configuration' => {
                                     'user'     => 'sling',
                                     'password' => 'BRQ4p5tKpAun8iCX5PRQ',
                                     'host'     => 'foo.example.com',
                                     'database' => 'mydb'
                                   }
              ) }

              it { is_expected.to contain_file('parquetdump_to_gcs').with_content(/^database_name=mydb$/) }

              it { is_expected.to contain_profiles__sling__connection('mydb').that_requires('Profiles::Mysql::App_user[sling@mydb]') }
            end
          end
        end
      end

      context 'on node node2.example.com' do
        let(:node) { 'node2.example.com' }

        context 'with database_name => mydb, database_host => db.example.com' do
          let(:params) { {
            'database_name' => 'mydb',
            'database_host' => 'db.example.com'
          } }

          context 'with hieradata' do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to contain_class('profiles::data_integration') }

            it { is_expected.to contain_profiles__mysql__app_user('sling@mydb').with(
              'user'     => 'sling',
              'database' => 'mydb',
              'tables'   => ['EVENTS_DBLOG', 'MAILINGSUBSCRIBER', 'MAILINGSUBSCRIPTION', 'DALISERVICECONSUMER'],
              'readonly' => true,
              'remote'   => true,
              'password' => 'JlCofI8ujmlsHtfQjlNf'
            ) }

            it { is_expected.to contain_profiles__sling__connection('mydb').with(
              'type'          => 'mysql',
              'configuration' => {
                                   'user'     => 'sling',
                                   'password' => 'JlCofI8ujmlsHtfQjlNf',
                                   'host'     => 'db.example.com',
                                   'database' => 'mydb'
                                 }
            ) }
          end
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_name'/) }
      end
    end
  end
end
