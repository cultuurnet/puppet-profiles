describe 'profiles::mongodb' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::mongodb').with(
          'version'               => 'installed',
          'listen_address'        => '127.0.0.1',
          'service_status'        => 'running',
          'lvm'                   => false,
          'volume_group'          => nil,
          'volume_size'           => nil,
          'backup_lvm'            => false,
          'backup_volume_group'   => nil,
          'backup_volume_size'    => nil,
          'backup_schedule'       => nil,
          'backup_retention_days' => 7
        ) }

        it { is_expected.to contain_group('mongodb') }
        it { is_expected.to contain_user('mongodb') }

        it { is_expected.not_to contain_firewall('400 accept mongodb traffic') }

        it { is_expected.not_to contain_profiles__lvm__mount('mongodbdata') }
        it { is_expected.not_to contain_exec('create_mongodb_dbpath') }

        it { is_expected.to contain_class('mongodb::globals').with(
          'manage_package_repo' => false
        ) }

        it { is_expected.to contain_class('mongodb::server').with(
          'package_name'   => 'mongodb-server',
          'package_ensure' => 'installed',
          'service_manage' => true,
          'service_ensure' => 'running',
          'service_enable' => true,
          'user'           => 'mongodb',
          'group'          => 'mongodb',
          'bind_ip'        => ['127.0.0.1']
        ) }

        it { is_expected.to contain_package('mongo-tools').with(
          'ensure' => 'installed'
        ) }

        it { is_expected.to contain_class('profiles::mongodb::backup').with(
          'lvm'             => false,
          'volume_group'    => nil,
          'volume_size'     => nil,
          'backup_schedule' => nil,
          'retention_days'  => 7
        ) }

        it { is_expected.to contain_group('mongodb').that_comes_before('Class[mongodb::server]') }
        it { is_expected.to contain_user('mongodb').that_comes_before('Class[mongodb::server]') }
      end

      context "with volume_groups datavg and backupvg present" do
        let(:pre_condition) { ['volume_group { "datavg": ensure => "present" }', 'volume_group { "backupvg": ensure => "present" }'] }

        context "with version => 1.2.3, listen_address => 0.0.0.0, lvm => true, volume_group => datavg, volume_size => 20G, backup_lvm => true, backup_volume_group => backupvg, backup_volume_size => 5G, backup_schedule => hourly and backup_retention_days => 10" do
          let(:params) { {
            'version'               => '1.2.3',
            'listen_address'        => '0.0.0.0',
            'lvm'                   => true,
            'volume_group'          => 'datavg',
            'volume_size'           => '20G',
            'backup_lvm'            => true,
            'backup_volume_group'   => 'backupvg',
            'backup_volume_size'    => '5G',
            'backup_schedule'       => 'hourly',
            'backup_retention_days' => 10
          } }

          it { is_expected.to contain_firewall('400 accept mongodb traffic') }

          it { is_expected.to contain_class('mongodb::server').with(
            'package_ensure' => '1.2.3',
            'package_name'   => 'mongodb-server',
            'service_manage' => true,
            'service_ensure' => 'running',
            'service_enable' => true,
            'user'           => 'mongodb',
            'group'          => 'mongodb',
            'bind_ip'        => ['0.0.0.0'],
          ) }

          it { is_expected.to contain_profiles__lvm__mount('mongodbdata').with(
            'volume_group' => 'datavg',
            'size'         => '20G',
            'fs_type'      => 'ext4',
            'mountpoint'   => '/data/mongodb',
            'owner'        => 'mongodb',
            'group'        => 'mongodb'
          ) }

          it { is_expected.to contain_exec('create_mongodb_dbpath').with(
            'command'     => 'install -o mongodb -g mongodb -d /var/lib/mongodb',
            'path'        => ['/usr/sbin', '/usr/bin'],
            'logoutput'   => 'on_failure',
            'creates'     => '/var/lib/mongodb'
          ) }

          it { is_expected.to contain_mount('/var/lib/mongodb').with(
            'ensure'  => 'mounted',
            'device'  => '/data/mongodb',
            'fstype'  => 'none',
            'options' => 'rw,bind'
          ) }

          it { is_expected.to contain_class('profiles::mongodb::backup').with(
            'lvm'             => true,
            'volume_group'    => 'backupvg',
            'volume_size'     => '5G',
            'backup_schedule' => 'hourly',
            'retention_days'  => 10
          ) }

          it { is_expected.to contain_group('mongodb').that_comes_before('Profiles::Lvm::Mount[mongodbdata]') }
          it { is_expected.to contain_user('mongodb').that_comes_before('Profiles::Lvm::Mount[mongodbdata]') }
          it { is_expected.to contain_profiles__lvm__mount('mongodbdata').that_comes_before('Class[mongodb::server]') }
          it { is_expected.to contain_profiles__lvm__mount('mongodbdata').that_comes_before('Mount[/var/lib/mongodb]') }
          it { is_expected.to contain_exec('create_mongodb_dbpath').that_requires('Group[mongodb]') }
          it { is_expected.to contain_exec('create_mongodb_dbpath').that_requires('User[mongodb]') }
          it { is_expected.to contain_mount('/var/lib/mongodb').that_requires('Profiles::Lvm::Mount[mongodbdata]') }
          it { is_expected.to contain_mount('/var/lib/mongodb').that_requires('Exec[create_mongodb_dbpath]') }
          it { is_expected.to contain_mount('/var/lib/mongodb').that_comes_before('Class[mongodb::server]') }
        end
      end

      context "with volume_groups myvg and mybackupvg present" do
        let(:pre_condition) { ['volume_group { "myvg": ensure => "present" }', 'volume_group { "mybackupvg": ensure => "present" }'] }

        context "with lvm => true, volume_group => myvg, service_status => stopped, volume_size => 10G, backup_lvm => true, backup_volume_group => mybackupvg, backup_volume_size => 2G, backup_schedule => daily and backup_retention_days => 5" do
          let(:params) { {
            'service_status'        => 'stopped',
            'lvm'                   => true,
            'volume_group'          => 'myvg',
            'volume_size'           => '10G',
            'backup_lvm'            => true,
            'backup_volume_group'   => 'mybackupvg',
            'backup_volume_size'    => '2G',
            'backup_schedule'       => 'daily',
            'backup_retention_days' => 5
          } }

          it { is_expected.to contain_class('mongodb::server').with(
            'package_name'   => 'mongodb-server',
            'package_ensure' => 'installed',
            'service_manage' => true,
            'service_ensure' => 'stopped',
            'service_enable' => false,
            'user'           => 'mongodb',
            'group'          => 'mongodb',
            'bind_ip'        => ['127.0.0.1']
          ) }

          it { is_expected.to contain_profiles__lvm__mount('mongodbdata').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/mongodb',
            'owner'        => 'mongodb',
            'group'        => 'mongodb'
          ) }

          it { is_expected.to contain_class('profiles::mongodb::backup').with(
            'lvm'             => true,
            'volume_group'    => 'mybackupvg',
            'volume_size'     => '2G',
            'backup_schedule' => 'daily',
            'retention_days'  => 5
          ) }
        end
      end

      context "with lvm => true, volume_group => datavg" do
        let(:params) { {
          'lvm'          => true,
          'volume_group' => 'myvg'
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /with LVM enabled, expects a value for both 'volume_group' and 'volume_size'/) }
      end

      context "with lvm => true, volume_size => 100G" do
        let(:params) { {
          'lvm'         => true,
          'volume_size' => '100G'
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /with LVM enabled, expects a value for both 'volume_group' and 'volume_size'/) }
      end
    end
  end
end
