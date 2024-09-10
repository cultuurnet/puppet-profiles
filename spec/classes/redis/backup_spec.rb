describe 'profiles::redis::backup' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::redis::backup').with(
          'lvm'            => false,
          'volume_group'   => nil,
          'volume_size'    => nil,
          'schedule'       => nil,
          'retention_days' => 7
        ) }

        it { is_expected.to contain_file('/data') }
        it { is_expected.to contain_file('/data/backup') }
        it { is_expected.to contain_file('/data/backup/redis').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/data/backup/redis/current').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/data/backup/redis/archive').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_cron('redis backup').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_file('/data/backup/redis').that_requires('File[/data/backup]') }
        it { is_expected.to contain_file('/data/backup/redis/current').that_requires('File[/data/backup/redis]') }
        it { is_expected.to contain_file('/data/backup/redis/archive').that_requires('File[/data/backup/redis]') }
        it { is_expected.to contain_cron('redis backup').that_requires('File[/data/backup/redis/current]') }
        it { is_expected.to contain_cron('redis backup').that_requires('File[/data/backup/redis/archive]') }
      end

      context "with lvm => true, volume_group => backupvg, volume_size => 20G, schedule => daily and retention_days => 10" do
        let(:params) { {
          'lvm'            => true,
          'volume_group'   => 'backupvg',
          'volume_size'    => '20G',
          'schedule'       => 'daily',
          'retention_days' => 10
        } }

        context "with volume_group backupvg present" do
          let(:pre_condition) { 'volume_group { "backupvg": ensure => "present" }' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__lvm__mount('redisbackup').with(
            'volume_group' => 'backupvg',
            'size'         => '20G',
            'mountpoint'   => '/data/backup/redis',
            'fs_type'      => 'ext4'
          ) }

          it { is_expected.to contain_cron('redis backup').with(
            'ensure'      => 'present',
            'command'     => '/usr/local/sbin/redisbackup.sh',
            'environment' => ['TZ=Europe/Brussels', 'MAILTO=infra+cron@publiq.be'],
            'user'        => 'root',
            'hour'        => '0',
            'minute'      => '20',
            'weekday'     => '*',
            'monthday'    => '*',
            'month'       => '*'
          ) }
        end
      end

      context "with lvm => true, volume_group => myvg, schedule => hourly and volume_size => 10G" do
        let(:params) { {
          'lvm'          => true,
          'volume_group' => 'myvg',
          'volume_size'  => '10G',
          'schedule'     => 'hourly'
        } }

        context "with volume_group myvg present" do
          let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_cron('redis backup').with(
            'ensure'      => 'present',
            'command'     => '/usr/local/sbin/redisbackup.sh',
            'environment' => ['TZ=Europe/Brussels', 'MAILTO=infra+cron@publiq.be'],
            'user'        => 'root',
            'hour'        => '*',
            'minute'      => '20',
            'weekday'     => '*',
            'monthday'    => '*',
            'month'       => '*'
          ) }

          it { is_expected.to contain_profiles__lvm__mount('redisbackup').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/backup/redis',
            'fs_type'      => 'ext4'
          ) }
        end
      end
    end
  end
end
