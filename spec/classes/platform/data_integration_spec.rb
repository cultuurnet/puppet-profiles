describe 'profiles::platform::data_integration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'on node node1.example.com' do
        let(:node) { 'node1.example.com' }

        context 'with database_name => foobar' do
          let(:params) { {
            'database_name' => 'foobar'
          } }

          context 'without extra parameters' do
            let(:params) { super() }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::platform::data_integration').with(
              'database_name'     => 'foobar',
              'dump_empty_tables' => true,
              'cron_hour'         => 2,
              'timezone'          => 'UTC'
            ) }

            it { is_expected.to contain_class('profiles::data_integration') }

            it { is_expected.to have_profiles__mysql__app_user_resource_count(1) }

            it { is_expected.to contain_profiles__mysql__app_user('sling@foobar').with(
              'user'     => 'sling',
              'database' => 'foobar',
              'tables'   => '*',
              'readonly' => true,
              'remote'   => false,
              'password' => 'vJfJpAzTHXt3NeFXaupK'
            ) }

            it { is_expected.to contain_profiles__sling__connection('foobar').with(
              'type'          => 'mysql',
              'configuration' => {
                                   'user'     => 'sling',
                                   'password' => 'vJfJpAzTHXt3NeFXaupK',
                                   'host'     => '127.0.0.1',
                                   'database' => 'foobar'
                                 }
            ) }

            it { is_expected.to contain_file('parquetdump_to_gcs').with(
              'ensure' => 'file',
              'path'   => '/usr/local/bin/parquetdump_to_gcs',
              'mode'   => '0755'
            ) }

            it { is_expected.to contain_file('parquetdump_to_gcs').with_content(/^database_name=foobar$/) }
            it { is_expected.to contain_file('parquetdump_to_gcs').with_content(/^database_password=vJfJpAzTHXt3NeFXaupK$/) }
            it { is_expected.to contain_file('parquetdump_to_gcs').with_content(/^dump_empty_tables=true$/) }

            it { is_expected.to contain_cron('parquetdump_to_gcs').with(
              'ensure'      => 'present',
              'command'     => '/usr/local/bin/parquetdump_to_gcs',
              'environment' => ['SHELL=/bin/bash', 'TZ=UTC', 'MAILTO=infra+cron@publiq.be'],
              'hour'        => 2,
              'minute'      => 0
            ) }

            it { is_expected.to contain_profiles__sling__connection('foobar').that_requires('Profiles::Mysql::App_user[sling@foobar]') }
            it { is_expected.to contain_file('parquetdump_to_gcs').that_requires('Class[profiles::data_integration]') }
            it { is_expected.to contain_file('parquetdump_to_gcs').that_requires('Profiles::Sling::Connection[foobar]') }
            it { is_expected.to contain_cron('parquetdump_to_gcs').that_requires('File[parquetdump_to_gcs]') }
          end
        end
      end

      context 'on node node2.example.com' do
        let(:node) { 'node2.example.com' }

        context 'with database_name => mydb' do
          let(:params) { {
            'database_name'     => 'mydb',
            'dump_empty_tables' => false,
            'cron_hour'         => 3,
            'timezone'          => 'CEST'
          } }

          it { is_expected.to contain_class('profiles::data_integration') }

          it { is_expected.to contain_profiles__mysql__app_user('sling@mydb').with(
            'user'     => 'sling',
            'database' => 'mydb',
            'tables'   => '*',
            'readonly' => true,
            'remote'   => false,
            'password' => 'JlCofI8ujmlsHtfQjlNf'
          ) }

          it { is_expected.to contain_profiles__sling__connection('mydb').with(
            'type'          => 'mysql',
            'configuration' => {
                                 'user'     => 'sling',
                                 'password' => 'JlCofI8ujmlsHtfQjlNf',
                                 'host'     => '127.0.0.1',
                                 'database' => 'mydb'
                               }
          ) }

          it { is_expected.to contain_file('parquetdump_to_gcs').with_content(/^database_name=mydb$/) }
          it { is_expected.to contain_file('parquetdump_to_gcs').with_content(/^database_password=JlCofI8ujmlsHtfQjlNf$/) }
          it { is_expected.to contain_file('parquetdump_to_gcs').with_content(/^dump_empty_tables=false$/) }

          it { is_expected.to contain_cron('parquetdump_to_gcs').with(
            'ensure'      => 'present',
            'command'     => '/usr/local/bin/parquetdump_to_gcs',
            'environment' => ['SHELL=/bin/bash', 'TZ=CEST', 'MAILTO=infra+cron@publiq.be'],
            'hour'        => 3,
            'minute'      => 0
          ) }

          it { is_expected.to contain_profiles__sling__connection('mydb').that_requires('Profiles::Mysql::App_user[sling@mydb]') }
          it { is_expected.to contain_file('parquetdump_to_gcs').that_requires('Profiles::Sling::Connection[mydb]') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_name'/) }
      end
    end
  end
end
