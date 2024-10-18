describe 'profiles::mysql::server' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::mysql::server').with(
          'root_password'         => nil,
          'listen_address'        => '127.0.0.1',
          'monitoring'            => false,
          'lvm'                   => false,
          'volume_group'          => nil,
          'volume_size'           => nil,
          'backup_lvm'            => false,
          'backup_volume_group'   => nil,
          'backup_volume_size'    => nil,
          'max_open_files'        => 1024,
          'long_query_time'       => 2,
          'backup_retention_days' => 7,
          'transaction_isolation' => 'REPEATABLE-READ',
          'event_scheduler'       => 'OFF'
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

        it { is_expected.to contain_profiles__mysql__root_my_cnf('localhost').with(
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
                                                  'transaction_isolation'          => 'REPEATABLE-READ',
                                                  'event_scheduler'                => 'OFF'
                                                }
                                  }
        ) }

        it { is_expected.to contain_class('profiles::mysql::server::backup').with(
          'password'       => '6oUtalmOuraT8IcBhCMq',
          'lvm'            => false,
          'volume_group'   => nil,
          'volume_size'    => nil,
          'retention_days' => 7
        ) }

        it { is_expected.to contain_class('profiles::mysql::server::logging') }

        it { is_expected.not_to contain_class('profiles::mysql::server::monitoring') }

        it { is_expected.to contain_group('mysql').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_user('mysql').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_profiles__mysql__root_my_cnf('localhost').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').that_notifies('Class[mysql::server::service]') }
        it { is_expected.to contain_class('mysql::server').that_comes_before('Class[profiles::mysql::server::backup]') }
        it { is_expected.to contain_class('mysql::server').that_comes_before('Class[profiles::mysql::server::logging]') }
      end

      context 'with volume_groups datavg and backupvg  present' do
        let(:pre_condition) { 'volume_group { ["datavg", "backupvg"]: ensure => "present" }' }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'with root_password => test, listen_address => 0.0.0.0, long_query_time => 5, max_open_files => 5120, monitoring => true, lvm => true, volume_group => datavg, volume_size => 20G, backup_lvm => true, backup_volume_group => backupvg, backup_volume_size => 10G and backup_retention_days => 5' do
            let(:params) { {
              'root_password'         => 'test',
              'listen_address'        => '0.0.0.0',
              'max_open_files'        => 5120,
              'monitoring'            => true,
              'lvm'                   => true,
              'volume_group'          => 'datavg',
              'volume_size'           => '20G',
              'backup_lvm'            => true,
              'backup_volume_group'   => 'backupvg',
              'backup_volume_size'    => '10G',
              'long_query_time'       => 5,
              'backup_retention_days' => 5,
              'transaction_isolation' => 'READ-COMMITTED',
              'event_scheduler'       => 'OFF'
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

            it { is_expected.to contain_profiles__mysql__root_my_cnf('localhost').with(
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
                                                      'transaction_isolation'          => 'READ-COMMITTED',
                                                      'event_scheduler'                => 'OFF'
                                                    }
                                      }

            ) }

            it { is_expected.to contain_class('profiles::mysql::server::monitoring') }

            it { is_expected.to contain_class('profiles::mysql::server::backup').with(
              'password'       => 'WyT9DYvR7jMg62EmF3kJ',
              'lvm'            => true,
              'volume_group'   => 'backupvg',
              'volume_size'    => '10G',
              'retention_days' => 5
            ) }

            it { is_expected.to contain_mysql_user('root@%').that_requires('Class[mysql::server]') }
            it { is_expected.to contain_mysql_user('root@%').that_requires('Profiles::Mysql::Root_my_cnf[localhost]') }
            it { is_expected.to contain_mysql_grant('root@%/*.*').that_requires('Class[mysql::server]') }
            it { is_expected.to contain_mysql_grant('root@%/*.*').that_requires('Profiles::Mysql::Root_my_cnf[localhost]') }
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
            it { is_expected.to contain_class('profiles::mysql::server::monitoring').that_requires('Class[mysql::server]') }

            context 'on node db.example.com with mysqld_version fact available' do
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

              it { expect(exported_resources).to contain_profiles__mysql__root_my_cnf('db.example.com').with(
                'database_user'     => 'root',
                'database_password' => 'test'
              ) }

              it { is_expected.to contain_profiles__mysql__root_my_cnf('localhost').with(
                'database_user'     => 'root',
                'database_password' => 'test'
              ) }

              it { is_expected.to contain_class('profiles::mysql::server::backup').with(
                'password'     => 'cUNSGcrB5ebQLnO902Y6',
                'lvm'          => true,
                'volume_group' => 'backupvg',
                'volume_size'  => '10G'
              ) }
            end

            context 'on node mydb.example.com' do
              let(:facts) {
                facts.merge( { 'networking' => { 'fqdn' => 'mydb.example.com' } } )
              }

              it { is_expected.to contain_class('profiles::mysql::server::backup').with(
                'password'     => 'MlTwrxl3cgW1uK4RNd5f',
                'lvm'          => true,
                'volume_group' => 'backupvg',
                'volume_size'  => '10G'
              ) }
            end
          end
        end
      end

      context 'with volume_groups myvg and mybackupvg present' do
        let(:pre_condition) { 'volume_group { ["myvg", "mybackupvg"]: ensure => "present" }' }

        context 'with root_password => foobar, max_open_files => 2048, lvm => true, volume_group => myvg, volume_size => 10G, backup_lvm => true, backup_volume_group => mybackupvg and backup_volume_size => 8G' do
          let(:params) { {
            'root_password'       => 'foobar',
            'max_open_files'      => 2048,
            'lvm'                 => true,
            'volume_group'        => 'myvg',
            'volume_size'         => '10G',
            'backup_lvm'          => true,
            'backup_volume_group' => 'mybackupvg',
            'backup_volume_size'  => '8G',
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

          it { is_expected.to contain_profiles__mysql__root_my_cnf('localhost').with(
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

          it { is_expected.to contain_class('profiles::mysql::server::backup').with(
            'password'     => 'Mt152RgDxtVQoAPmoXoH',
            'lvm'          => true,
            'volume_group' => 'mybackupvg',
            'volume_size'  => '8G'
          ) }
        end
      end
    end
  end
end
