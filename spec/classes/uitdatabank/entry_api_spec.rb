describe 'profiles::uitdatabank::entry_api' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with database_password => mypassword' do
        let(:params) { {
          'database_password' => 'mypassword'
        } }

        context "with class profiles::mysql::server present" do
          let(:pre_condition) { 'include profiles::mysql::server' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api').with(
            'database_password' => 'mypassword',
            'database_host'     => '127.0.0.1',
            'deployment'        => true
          ) }

          it { is_expected.to contain_class('profiles::mysql::server') }
          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment') }
          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::data_integration').with(
            'database_name' => 'uitdatabank'
          ) }

          it { is_expected.to contain_mysql_database('uitdatabank').with(
            'charset' => 'utf8mb4',
            'collate' => 'utf8mb4_0900_ai_ci'
          ) }

          it { is_expected.to contain_profiles__mysql__app_user('entry_api@uitdatabank').with(
            'password' => 'mypassword',
            'remote'   => false
          ) }

          it { is_expected.to contain_mysql_database('uitdatabank').that_comes_before('Profiles::Mysql::App_user[entry_api@uitdatabank]') }
          it { is_expected.to contain_mysql_database('uitdatabank').that_requires('Class[profiles::mysql::server]') }
          it { is_expected.to contain_profiles__mysql__app_user('entry_api@uitdatabank').that_comes_before('Class[profiles::uitdatabank::entry_api::deployment]') }
          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::data_integration').that_requires('Class[profiles::uitdatabank::entry_api::deployment]') }
        end
      end

      context 'with database_password => secret, database_host => foo.example.com and deployment => false' do
        let(:params) { {
          'database_password' => 'secret',
          'database_host'     => 'foo.example.com',
          'deployment'        => false
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::mysql::remote_server').with(
          'host' => 'foo.example.com'
        ) }

        it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::deployment') }
        it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::data_integration') }

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

      context 'with database_password => mypassword and database_host => bar.example.com' do
        let(:params) { {
          'database_password' => 'mypassword',
          'database_host'     => 'bar.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::mysql::remote_server').with(
          'host' => 'bar.example.com'
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

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_password'/) }
      end
    end
  end
end
