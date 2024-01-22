describe 'profiles::mysql::server' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::mysql::server').with(
          'root_password'  => nil,
          'lvm'            => false,
          'volume_group'   => nil,
          'volume_size'    => nil,
          'max_open_files' => 1024
        ) }

        it { is_expected.to contain_group('mysql') }
        it { is_expected.to contain_user('mysql') }

        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').with(
          'unit'          => 'mysql.service',
          'filename'      => 'override.conf',
          'content'       => "[Service]\nLimitNOFILE=1024"
        ) }

        it { is_expected.to contain_file('root_my_cnf').with(
          'ensure' => 'file',
          'path'   => '/root/.my.cnf',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0400'
        ) }

        it { is_expected.to contain_file('root_my_cnf').with_content(/^\[client\]\nuser=root\npassword=''\nhost=127\.0\.0\.1\n$/) }

        it { is_expected.to contain_class('mysql::server').with(
          'root_password'      => 'UNSET',
          'create_root_my_cnf' => false,
          'restart'            => true,
          'override_options'   => {
                                    'client' => { 'default-character-set' => 'utf8mb4' },
                                    'mysql'  => { 'default-character-set' => 'utf8mb4' },
                                    'mysqld' => {
                                                  'character-set-client-handshake' => 'false',
                                                  'character-set-server'           => 'utf8mb4',
                                                  'collation-server'               => 'utf8mb4_unicode_ci',
                                                  'bind-address'                   => '0.0.0.0',
                                                  'ignore-db-dir'                  => 'lost+found',
                                                  'skip-name-resolve'              => 'true',
                                                  'innodb_file_per_table'          => 'ON',
                                                  'slow_query_log'                 => 'ON',
                                                  'slow_query_log_file'            => '/var/log/mysql/slow-query.log',
                                                  'long_query_time'                => '4'
                                                }
                                  }
        ) }

        it { is_expected.to contain_class('profiles::mysql::logging') }

        it { is_expected.to contain_group('mysql').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_user('mysql').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_file('root_my_cnf').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').that_notifies('Class[mysql::server::service]') }
        it { is_expected.to contain_class('mysql::server').that_comes_before('Class[profiles::mysql::logging]') }
      end

      context "with root_password => test, max_open_files => 5120" do
        let(:params) { {
          'root_password'  => 'test',
          'max_open_files' => 5120
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').with(
          'unit'          => 'mysql.service',
          'filename'      => 'override.conf',
          'content'       => "[Service]\nLimitNOFILE=5120"
        ) }

        it { is_expected.to contain_file('root_my_cnf').with_content(/^\[client\]\nuser=root\npassword='test'\nhost=127\.0\.0\.1\n$/) }

        it { is_expected.to contain_class('mysql::server').with(
          'root_password'      => 'test',
          'create_root_my_cnf' => false,
          'restart'            => true
        ) }
      end
    end
  end
end
