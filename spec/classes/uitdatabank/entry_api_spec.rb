describe 'profiles::uitdatabank::entry_api' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with database_password => mypassword, servername => uitdatabank.example.com and job_interface_servername => jobs.example.com' do
          let(:params) { {
            'database_password'        => 'mypassword',
            'servername'               => 'uitdatabank.example.com',
            'job_interface_servername' => 'jobs.example.com'
          } }

          context "with class profiles::mysql::server present" do
            let(:pre_condition) { 'include profiles::mysql::server' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_apt__source('publiq-tools') }
            it { is_expected.to contain_package('prince') }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api').with(
              'database_password'                 => 'mypassword',
              'database_host'                     => '127.0.0.1',
              'servername'                        => 'uitdatabank.example.com',
              'job_interface_servername'          => 'jobs.example.com',
              'uitpas_servername'                 => nil,
              'deployment'                        => true,
              'schedule_process_duplicates'       => false,
              'schedule_movie_fetcher'            => false,
              'schedule_add_trailers'             => false,
              'schedule_replay_mismatched_events' => false
            ) }

            it { is_expected.to contain_class('profiles::mysql::server') }
            it { is_expected.to contain_class('profiles::redis') }
            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment') }
            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::data_integration').with(
              'database_name' => 'uitdatabank'
            ) }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::cron').with(
              'basedir'                           => '/var/www/udb3-backend',
              'schedule_process_duplicates'       => false,
              'schedule_movie_fetcher'            => false,
              'schedule_add_trailers'             => false,
              'schedule_replay_mismatched_events' => false
            ) }

            it { is_expected.to contain_mysql_database('uitdatabank').with(
              'charset' => 'utf8mb4',
              'collate' => 'utf8mb4_0900_ai_ci'
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('entry_api@uitdatabank').with(
              'password' => 'mypassword',
              'remote'   => false
            ) }

            it { is_expected.to contain_class('profiles::uitdatabank::resque_web').with(
              'servername' => 'jobs.example.com'
            ) }

            it { is_expected.to contain_package('prince').that_requires('Apt::Source[publiq-tools]') }
            it { is_expected.to contain_mysql_database('uitdatabank').that_comes_before('Profiles::Mysql::App_user[entry_api@uitdatabank]') }
            it { is_expected.to contain_mysql_database('uitdatabank').that_requires('Class[profiles::mysql::server]') }
            it { is_expected.to contain_profiles__mysql__app_user('entry_api@uitdatabank').that_comes_before('Class[profiles::uitdatabank::entry_api::deployment]') }
            it { is_expected.to contain_class('profiles::redis').that_comes_before('Class[profiles::uitdatabank::entry_api::deployment]') }
            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::data_integration').that_requires('Class[profiles::uitdatabank::entry_api::deployment]') }
            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::cron').that_requires('Class[profiles::uitdatabank::entry_api::deployment]') }
          end
        end

        context 'with database_password => secret, database_host => foo.example.com, servername => uitdatabank.example.com, job_interface_servername => bar.example.com, uitpas_servername => uitpas.example.com and deployment => false' do
          let(:params) { {
            'database_password'        => 'secret',
            'database_host'            => 'foo.example.com',
            'servername'               => 'uitdatabank.example.com',
            'job_interface_servername' => 'bar.example.com',
            'uitpas_servername'        => 'uitpas.example.com',
            'deployment'               => false
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::mysql::remote_server').with(
            'host' => 'foo.example.com'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::resque_web').with(
            'servername' => 'bar.example.com'
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://uitpas.example.com').with(
            'destination' => 'https://uitdatabank.example.com/uitpas/'
          ) }

          it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::deployment') }
          it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::data_integration') }
          it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::cron') }

          context "with fact mysqld_version => 8.0.33" do
            let(:facts) { facts.merge( { 'mysqld_version' => '8.0.33' } ) }

            it { is_expected.to contain_mysql_database('uitdatabank').with(
              'charset' => 'utf8mb4',
              'collate' => 'utf8mb4_0900_ai_ci'
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('entry_api@uitdatabank').with(
              'password' => 'secret',
              'remote'   => true
            ) }

            it { is_expected.to contain_mysql_database('uitdatabank').that_comes_before('Profiles::Mysql::App_user[entry_api@uitdatabank]') }
          end

          context "without extra facts" do
            it { is_expected.not_to contain_mysql_database('uitdatabank') }
            it { is_expected.not_to contain_profiles__mysql__app_user('entry_api@uitdatabank') }
          end
        end

        context 'with database_password => mypassword, database_host => bar.example.com, servername => foo.example.com, job_interface_servername => baz.example.com, uitpas_servername => myuitpas.example.com, schedule_process_duplicates => true, schedule_movie_fetcher => true, schedule_add_trailers => true and schedule_replay_mismatched_events => true' do
          let(:params) { {
            'database_password'                 => 'mypassword',
            'database_host'                     => 'bar.example.com',
            'servername'                        => 'foo.example.com',
            'job_interface_servername'          => 'baz.example.com',
            'uitpas_servername'                 => 'myuitpas.example.com',
            'schedule_process_duplicates'       => true,
            'schedule_movie_fetcher'            => true,
            'schedule_add_trailers'             => true,
            'schedule_replay_mismatched_events' => true
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::mysql::remote_server').with(
            'host' => 'bar.example.com'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::resque_web').with(
            'servername' => 'baz.example.com'
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://myuitpas.example.com').with(
            'destination' => 'https://foo.example.com/uitpas/'
          ) }

          context "with fact mysqld_version => 8.0.33" do
            let(:facts) { facts.merge( { 'mysqld_version' => '8.0.33' } ) }

            it { is_expected.to contain_mysql_database('uitdatabank').with(
              'charset' => 'utf8mb4',
              'collate' => 'utf8mb4_0900_ai_ci'
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('entry_api@uitdatabank').with(
              'password' => 'mypassword',
              'remote'   => true
            ) }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment') }
            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::data_integration').with(
              'database_name' => 'uitdatabank'
            ) }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::cron').with(
              'basedir'                           => '/var/www/udb3-backend',
              'schedule_process_duplicates'       => true,
              'schedule_movie_fetcher'            => true,
              'schedule_add_trailers'             => true,
              'schedule_replay_mismatched_events' => true
            ) }

            it { is_expected.to contain_mysql_database('uitdatabank').that_comes_before('Profiles::Mysql::App_user[entry_api@uitdatabank]') }
            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::data_integration').that_requires('Class[profiles::uitdatabank::entry_api::deployment]') }
          end

          context "without extra facts" do
            it { is_expected.not_to contain_mysql_database('uitdatabank') }
            it { is_expected.not_to contain_profiles__mysql__app_user('entry_api@uitdatabank') }
            it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::deployment') }
            it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::data_integration') }
          end
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_password'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'job_interface_servername'/) }
      end
    end
  end
end
