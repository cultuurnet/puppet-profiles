describe 'profiles::redis' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::redis').with(
          'version'               => 'installed',
          'listen_address'        => '127.0.0.1',
          'persist_data'          => true,
          'appendonly'            => false,
          'password'              => nil,
          'lvm'                   => false,
          'volume_group'          => nil,
          'volume_size'           => nil,
          'backup_lvm'            => false,
          'backup_volume_group'   => nil,
          'backup_volume_size'    => nil,
          'backup_schedule'       => nil,
          'backup_retention_days' => 7,
          'maxmemory'             => nil,
          'maxmemory_policy'      => nil
        ) }

        it { is_expected.to contain_group('redis') }
        it { is_expected.to contain_user('redis') }

        it { is_expected.not_to contain_firewall('400 accept redis traffic') }

        it { is_expected.to contain_class('redis').with(
          'package_ensure'   => 'installed',
          'workdir'          => '/var/lib/redis',
          'save_db_to_disk'  => true,
          'appendonly'       => false,
          'workdir_mode'     => '0755',
          'bind'             => '127.0.0.1',
          'requirepass'      => nil,
          'service_manage'   => false,
          'maxmemory'        => nil,
          'maxmemory_policy' => nil
        ) }

        it { is_expected.to contain_class('profiles::redis::backup').with(
          'lvm'             => false,
          'volume_group'    => nil,
          'volume_size'     => nil,
          'backup_schedule' => nil,
          'retention_days'  => 7
        ) }

        it { is_expected.to contain_service('redis-server').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_group('redis').that_comes_before('Class[redis]') }
        it { is_expected.to contain_user('redis').that_comes_before('Class[redis]') }
        it { is_expected.to contain_class('redis').that_notifies('Service[redis-server]') }
      end

      context "with volume_groups datavg and backupvg present" do
        let(:pre_condition) { ['volume_group { "datavg": ensure => "present" }', 'volume_group { "backupvg": ensure => "present" }'] }

        context "with version => 1.2.3, listen_address => 0.0.0.0, password => mypass, appendonly => true, lvm => true, volume_group => datavg, volume_size => 20G, backup_lvm => true, backup_volume_group => backupvg, backup_volume_size => 5G, backup_schedule => hourly and backup_retention_days => 10" do
          let(:params) { {
            'version'               => '1.2.3',
            'listen_address'        => '0.0.0.0',
            'password'              => 'mypass',
            'persist_data'          => true,
            'appendonly'            => true,
            'lvm'                   => true,
            'volume_group'          => 'datavg',
            'volume_size'           => '20G',
            'backup_lvm'            => true,
            'backup_volume_group'   => 'backupvg',
            'backup_volume_size'    => '5G',
            'backup_schedule'       => 'hourly',
            'backup_retention_days' => 10
          } }

          it { is_expected.to contain_firewall('400 accept redis traffic') }

          it { is_expected.to contain_class('redis').with(
            'package_ensure'   => '1.2.3',
            'bind'             => '0.0.0.0',
            'requirepass'      => 'mypass',
            'save_db_to_disk'  => true,
            'appendonly'       => true,
            'maxmemory'        => nil,
            'maxmemory_policy' => nil
          ) }

          it { is_expected.to contain_profiles__lvm__mount('redisdata').with(
            'volume_group' => 'datavg',
            'size'         => '20G',
            'fs_type'      => 'ext4',
            'mountpoint'   => '/data/redis',
            'owner'        => 'redis',
            'group'        => 'redis'
          ) }

          it { is_expected.to contain_class('profiles::redis::backup').with(
            'lvm'             => true,
            'volume_group'    => 'backupvg',
            'volume_size'     => '5G',
            'backup_schedule' => 'hourly',
            'retention_days'  => 10
          ) }

          it { is_expected.to contain_group('redis').that_comes_before('Profiles::Lvm::Mount[redisdata]') }
          it { is_expected.to contain_user('redis').that_comes_before('Profiles::Lvm::Mount[redisdata]') }
          it { is_expected.to contain_profiles__lvm__mount('redisdata').that_comes_before('Class[redis]') }
          it { is_expected.to contain_profiles__lvm__mount('redisdata').that_comes_before('Mount[/var/lib/redis]') }
          it { is_expected.to contain_mount('/var/lib/redis').that_requires('Profiles::Lvm::Mount[redisdata]') }
          it { is_expected.to contain_mount('/var/lib/redis').that_requires('Class[redis]') }
          it { is_expected.to contain_mount('/var/lib/redis').that_notifies('Service[redis-server]') }
        end
      end

      context "with volume_groups myvg and mybackupvg present" do
        let(:pre_condition) { ['volume_group { "myvg": ensure => "present" }', 'volume_group { "mybackupvg": ensure => "present" }'] }

        context "with lvm => true, volume_group => myvg, volume_size => 10G, backup_lvm => true, backup_volume_group => mybackupvg, backup_volume_size => 2G, backup_schedule => daily and backup_retention_days => 5" do
          let(:params) { {
            'lvm'                   => true,
            'volume_group'          => 'myvg',
            'volume_size'           => '10G',
            'backup_lvm'            => true,
            'backup_volume_group'   => 'mybackupvg',
            'backup_volume_size'    => '2G',
            'backup_schedule'       => 'daily',
            'backup_retention_days' => 5
          } }

          it { is_expected.to contain_profiles__lvm__mount('redisdata').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/redis',
            'owner'        => 'redis',
            'group'        => 'redis'
          ) }

          it { is_expected.to contain_class('profiles::redis::backup').with(
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

      context "with persist_data => false, maxmemory => 200mb and maxmemory_policy => noeviction" do
        let(:params) { {
          'persist_data'     => false,
          'maxmemory'        => '200mb',
          'maxmemory_policy' => 'noeviction'
        } }

        it { is_expected.to contain_class('redis').with(
          'package_ensure'   => 'installed',
          'workdir'          => '/var/lib/redis',
          'save_db_to_disk'  => false,
          'appendonly'       => false,
          'workdir_mode'     => '0755',
          'bind'             => '127.0.0.1',
          'requirepass'      => nil,
          'service_manage'   => false,
          'maxmemory'        => '200mb',
          'maxmemory_policy' => 'noeviction'
        ) }

        it { is_expected.not_to contain_class('profiles::redis::backup') }
      end

      context "with persist_data => false, appendonly => true" do
        let(:params) { {
          'persist_data' => false,
          'appendonly'   => true
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /with appendonly enabled, 'persist_data' must be set to true/) }
      end
     end
   end
 end
