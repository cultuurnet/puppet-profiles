describe 'profiles::mysql::server::backup' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        context "with class profiles::mysql::server present" do
          let(:pre_condition) { 'include profiles::mysql::server' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::mysql::server::backup').with(
            'password'     => nil,
            'lvm'          => false,
            'volume_group' => nil,
            'volume_size'  => nil
          ) }

          it { is_expected.to contain_file('/data') }
          it { is_expected.to contain_file('/data/backup') }
          it { is_expected.to contain_file('/data/backup/mysql').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755'
          ) }

          it { is_expected.to contain_file('/data/backup/mysql/archive').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755'
          ) }

          it { is_expected.to contain_class('mysql::server::backup').with(
            'backupuser'         => 'backup',
            'backuppassword'     => nil,
            'backupdir'          => '/data/backup/mysql/current',
            'backuprotate'       => 1,
            'file_per_database'  => true,
            'delete_before_dump' => true,
            'time'               => [1, 5],
            'postscript'         => 'cp /data/backup/mysql/current/* /data/backup/mysql/archive',
            'excludedatabases'   => ['mysql', 'sys', 'information_schema', 'performance_schema']
          ) }

          it { is_expected.to contain_file('/data/backup/mysql').that_requires('File[/data/backup]') }
          it { is_expected.to contain_file('/data/backup/mysql/archive').that_requires('File[/data/backup/mysql]') }
          it { is_expected.to contain_file('/data/backup/mysql').that_comes_before('Class[mysql::server::backup]') }
          it { is_expected.to contain_file('/data/backup/mysql/archive').that_comes_before('Class[mysql::server::backup]') }
        end
      end

      context "with password => secret, lvm => true, volume_group => backupvg and volume_size => 20G" do
        let(:params) { {
          'password'     => 'secret',
          'lvm'          => true,
          'volume_group' => 'backupvg',
          'volume_size'  => '20G'
        } }

        context "with class profiles::mysql::server and volume_group backupvg present" do
          let(:pre_condition) { ['include profiles::mysql::server', 'volume_group { "backupvg": ensure => "present" }'] }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__lvm__mount('mysqlbackup').with(
            'volume_group' => 'backupvg',
            'size'         => '20G',
            'mountpoint'   => '/data/backup/mysql',
            'fs_type'      => 'ext4'
          ) }

          it { is_expected.to contain_class('mysql::server::backup').with(
            'backupuser'         => 'backup',
            'backuppassword'     => 'secret',
            'backupdir'          => '/data/backup/mysql/current',
            'backuprotate'       => 1,
            'file_per_database'  => true,
            'delete_before_dump' => true,
            'time'               => [1, 5],
            'postscript'         => 'cp /data/backup/mysql/current/* /data/backup/mysql/archive',
            'excludedatabases'   => ['mysql', 'sys', 'information_schema', 'performance_schema']
          ) }
        end
      end

      context "with password => foobar, lvm => true, volume_group => myvg and volume_size => 10G" do
        let(:params) { {
          'password'     => 'foobar',
          'lvm'          => true,
          'volume_group' => 'myvg',
          'volume_size'  => '10G'
        } }

        context "with class profiles::mysql::server and volume_group myvg present" do
          let(:pre_condition) { ['include profiles::mysql::server', 'volume_group { "myvg": ensure => "present" }'] }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__lvm__mount('mysqlbackup').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/backup/mysql',
            'fs_type'      => 'ext4'
          ) }

          it { is_expected.to contain_class('mysql::server::backup').with(
            'backupuser'         => 'backup',
            'backuppassword'     => 'foobar',
            'backupdir'          => '/data/backup/mysql/current',
            'backuprotate'       => 1,
            'file_per_database'  => true,
            'delete_before_dump' => true,
            'time'               => [1, 5],
            'postscript'         => 'cp /data/backup/mysql/current/* /data/backup/mysql/archive',
            'excludedatabases'   => ['mysql', 'sys', 'information_schema', 'performance_schema']
          ) }
        end
      end
    end
  end
end
