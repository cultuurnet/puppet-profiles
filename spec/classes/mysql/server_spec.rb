describe 'profiles::mysql::server' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::mysql::server').with(
          'root_password'         => nil,
          'listen_address'        => '127.0.0.1',
          'lvm'                   => false,
          'volume_group'          => nil,
          'volume_size'           => nil,
          'max_open_files'        => 1024,
          'long_query_time'       => 2,
          'transaction_isolation' => 'REPEATABLE-READ'
        ) }

        it { is_expected.not_to contain_profiles__lvm__mount('mysqldata') }
        it { is_expected.not_to contain_file('/data/mysql/lost+found') }
        it { is_expected.not_to contain_file('/var/lib/mysql') }
        it { is_expected.not_to contain_mount('/var/lib/mysql') }

        it { is_expected.not_to contain_firewall('400 accept mysql traffic') }

        it { is_expected.to contain_group('mysql') }
        it { is_expected.to contain_user('mysql') }

        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').with(
          'unit'          => 'mysql.service',
          'filename'      => 'override.conf',
          'content'       => "[Service]\nLimitNOFILE=1024"
        ) }

        it { is_expected.to contain_profiles__mysql__my_cnf('localhost').with(
          'database_user'     => 'root',
          'database_password' => nil
        ) }

        it { is_expected.not_to contain_mysql_user('root@%') }
        it { is_expected.not_to contain_mysql_grant('root@%/*.*') }

        it { is_expected.to contain_class('mysql::server').with(
          'root_password'      => 'UNSET',
          'package_name'       => 'mysql-server',
          'service_name'       => 'mysql',
          'create_root_my_cnf' => false,
          'managed_dirs'       => [],
          'restart'            => true,
          'override_options'   => {
                                    'client' => { 'default-character-set' => 'utf8mb4' },
                                    'mysql'  => { 'default-character-set' => 'utf8mb4' },
                                    'mysqld' => {
                                                  'character-set-client-handshake' => 'false',
                                                  'character-set-server'           => 'utf8mb4',
                                                  'collation-server'               => 'utf8mb4_unicode_ci',
                                                  'bind-address'                   => '127.0.0.1',
                                                  'skip-name-resolve'              => 'true',
                                                  'innodb_file_per_table'          => 'ON',
                                                  'slow_query_log'                 => 'ON',
                                                  'slow_query_log_file'            => '/var/log/mysql/slow-query.log',
                                                  'long_query_time'                => '2',
                                                  'transaction_isolation'          => 'REPEATABLE-READ'
                                                }
                                  }
        ) }

        it { is_expected.to contain_class('profiles::mysql::logging') }

        it { is_expected.to contain_group('mysql').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_user('mysql').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_profiles__mysql__my_cnf('localhost').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').that_notifies('Class[mysql::server::service]') }
        it { is_expected.to contain_class('mysql::server').that_comes_before('Class[profiles::mysql::logging]') }
      end

      context "with volume_group datavg present" do
        let(:pre_condition) { 'volume_group { "datavg": ensure => "present" }' }

        context "with root_password => test, listen_address => 0.0.0.0, long_query_time => 5, max_open_files => 5120, lvm => true, volume_group => datavg and volume_size => 20G" do
          let(:params) { {
            'root_password'         => 'test',
            'listen_address'        => '0.0.0.0',
            'max_open_files'        => 5120,
            'lvm'                   => true,
            'volume_group'          => 'datavg',
            'volume_size'           => '20G',
            'long_query_time'       => 5,
            'transaction_isolation' => 'READ-COMMITTED'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__lvm__mount('mysqldata').with(
            'volume_group' => 'datavg',
            'size'         => '20G',
            'mountpoint'   => '/data/mysql',
            'fs_type'      => 'ext4',
            'owner'        => 'mysql',
            'group'        => 'mysql'
          ) }

          it { is_expected.to contain_file('/data/mysql/lost+found').with(
            'ensure'  => 'absent',
            'force'   => true
          ) }

          it { is_expected.to contain_file('/var/lib/mysql').with(
            'ensure' => 'directory',
            'owner'  => 'mysql',
            'group'  => 'mysql'
          ) }

          it { is_expected.to contain_mount('/var/lib/mysql').with(
            'ensure'  => 'mounted',
            'device'  => '/data/mysql',
            'fstype'  => 'none',
            'options' => 'rw,bind'
          ) }

          it { is_expected.to contain_firewall('400 accept mysql traffic') }

          it { expect(exported_resources).not_to contain_file('mysqld_version_external_fact') }

          it { is_expected.to contain_systemd__dropin_file('mysql override.conf').with(
            'unit'          => 'mysql.service',
            'filename'      => 'override.conf',
            'content'       => "[Service]\nLimitNOFILE=5120"
          ) }

          it { is_expected.to contain_profiles__mysql__my_cnf('localhost').with(
            'database_user'     => 'root',
            'database_password' => 'test'
          ) }

          it { is_expected.to contain_mysql_user('root@%').with(
            'password_hash' => '*94BDCEBE19083CE2A1F959FD02F964C7AF4CFC29'
          ) }

          it { is_expected.to contain_mysql_grant('root@%/*.*').with(
            'user'       => 'root@%',
            'options'    => ['GRANT'],
            'privileges' => ['ALL'],
            'table'      => '*.*'
          ) }

          it { is_expected.to contain_class('mysql::server').with(
            'root_password'      => 'test',
            'package_name'       => 'mysql-server',
            'service_name'       => 'mysql',
            'create_root_my_cnf' => false,
            'managed_dirs'       => [],
            'restart'            => true,
            'override_options'   => {
                                      'client' => { 'default-character-set' => 'utf8mb4' },
                                      'mysql'  => { 'default-character-set' => 'utf8mb4' },
                                      'mysqld' => {
                                                    'character-set-client-handshake' => 'false',
                                                    'character-set-server'           => 'utf8mb4',
                                                    'collation-server'               => 'utf8mb4_unicode_ci',
                                                    'bind-address'                   => '0.0.0.0',
                                                    'skip-name-resolve'              => 'true',
                                                    'innodb_file_per_table'          => 'ON',
                                                    'slow_query_log'                 => 'ON',
                                                    'slow_query_log_file'            => '/var/log/mysql/slow-query.log',
                                                    'long_query_time'                => '5',
                                                    'transaction_isolation'          => 'READ-COMMITTED'
                                                  }
                                    }

          ) }

          it { is_expected.to contain_mysql_user('root@%').that_requires('Class[mysql::server]') }
          it { is_expected.to contain_mysql_user('root@%').that_requires('Profiles::Mysql::My_cnf[localhost]') }
          it { is_expected.to contain_mysql_grant('root@%/*.*').that_requires('Class[mysql::server]') }
          it { is_expected.to contain_mysql_grant('root@%/*.*').that_requires('Profiles::Mysql::My_cnf[localhost]') }
          it { is_expected.to contain_profiles__lvm__mount('mysqldata').that_requires('Group[mysql]') }
          it { is_expected.to contain_profiles__lvm__mount('mysqldata').that_requires('User[mysql]') }
          it { is_expected.to contain_profiles__lvm__mount('mysqldata').that_comes_before('Class[mysql::server]') }
          it { is_expected.to contain_file('/data/mysql/lost+found').that_requires('Profiles::Lvm::Mount[mysqldata]') }
          it { is_expected.to contain_file('/data/mysql/lost+found').that_comes_before('Class[mysql::server]') }
          it { is_expected.to contain_file('/var/lib/mysql').that_requires('Group[mysql]') }
          it { is_expected.to contain_file('/var/lib/mysql').that_requires('User[mysql]') }
          it { is_expected.to contain_file('/var/lib/mysql').that_requires('Profiles::Lvm::Mount[mysqldata]') }
          it { is_expected.to contain_file('/var/lib/mysql').that_comes_before('Class[mysql::server]') }
          it { is_expected.to contain_mount('/var/lib/mysql').that_notifies('Class[mysql::server::service]') }
          it { is_expected.to contain_mount('/var/lib/mysql').that_requires('Profiles::Lvm::Mount[mysqldata]') }
          it { is_expected.to contain_mount('/var/lib/mysql').that_requires('File[/var/lib/mysql]') }
          it { is_expected.to contain_mount('/var/lib/mysql').that_comes_before('Class[mysql::server]') }

          context "on node db.example.com with mysqld_version fact available" do
            let(:facts) {
              facts.merge( { 'networking' => { 'fqdn' => 'db.example.com' }, 'mysqld_version' => '8.0.33' } )
            }

            it { expect(exported_resources).to contain_file('mysqld_version_external_fact').with(
              'ensure'  => 'file',
              'path'    => '/etc/puppetlabs/facter/facts.d/mysqld_version.txt',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'content' => 'mysqld_version=8.0.33',
              'tag'     => ['mysqld_version', 'db.example.com']
            ) }

            it { expect(exported_resources).to contain_profiles__mysql__my_cnf('db.example.com').with(
              'database_user'     => 'root',
              'database_password' => 'test'
            ) }

            it { is_expected.to contain_profiles__mysql__my_cnf('localhost').with(
              'database_user'     => 'root',
              'database_password' => 'test'
            ) }
          end
        end
      end

      context "with volume_group myvg present" do
        let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

        context "with root_password => foobar, max_open_files => 2048, lvm => true, volume_group => myvg and volume_size => 10G" do
          let(:params) { {
            'root_password'  => 'foobar',
            'max_open_files' => 2048,
            'lvm'            => true,
            'volume_group'   => 'myvg',
            'volume_size'    => '10G'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__lvm__mount('mysqldata').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/mysql',
            'fs_type'      => 'ext4',
            'owner'        => 'mysql',
            'group'        => 'mysql'
          ) }

          it { is_expected.to contain_systemd__dropin_file('mysql override.conf').with(
            'unit'          => 'mysql.service',
            'filename'      => 'override.conf',
            'content'       => "[Service]\nLimitNOFILE=2048"
          ) }

          it { is_expected.to contain_profiles__mysql__my_cnf('localhost').with(
            'database_user'     => 'root',
            'database_password' => 'foobar',
          ) }

          it { is_expected.to contain_class('mysql::server').with(
            'root_password'      => 'foobar',
            'package_name'       => 'mysql-server',
            'service_name'       => 'mysql',
            'create_root_my_cnf' => false,
            'managed_dirs'       => [],
            'restart'            => true
          ) }
        end
      end
    end
  end
end
