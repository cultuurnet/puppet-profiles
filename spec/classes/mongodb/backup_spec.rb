describe 'profiles::mongodb::backup' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::mongodb::backup').with(
          'lvm'             => false,
          'volume_group'    => nil,
          'volume_size'     => nil,
          'backup_schedule' => nil,
          'retention_days'  => 7
        ) }

        it { is_expected.to contain_file('/data') }
        it { is_expected.to contain_file('/data/backup') }
        it { is_expected.to contain_file('/data/backup/mongodb').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/data/backup/mongodb/current').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/data/backup/mongodb/archive').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_cron('mongodb backup').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_file('/data/backup/mongodb').that_requires('File[/data/backup]') }
        it { is_expected.to contain_file('/data/backup/mongodb/current').that_requires('File[/data/backup/mongodb]') }
        it { is_expected.to contain_file('/data/backup/mongodb/archive').that_requires('File[/data/backup/mongodb]') }
        it { is_expected.to contain_cron('mongodb backup').that_requires('File[/data/backup/mongodb/current]') }
        it { is_expected.to contain_cron('mongodb backup').that_requires('File[/data/backup/mongodb/archive]') }
      end

      context "with lvm => true, volume_group => backupvg, volume_size => 20G, backup_schedule => daily and retention_days => 10" do
        let(:params) { {
          'lvm'             => true,
          'volume_group'    => 'backupvg',
          'volume_size'     => '20G',
          'backup_schedule' => 'daily',
          'retention_days'  => 10
        } }

        context "with volume_group backupvg present" do
          let(:pre_condition) { 'volume_group { "backupvg": ensure => "present" }' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__lvm__mount('mongodbbackup').with(
            'volume_group' => 'backupvg',
            'size'         => '20G',
            'mountpoint'   => '/data/backup/mongodb',
            'fs_type'      => 'ext4'
          ) }

          it { is_expected.to contain_cron('mongodb backup').with(
            'ensure'      => 'present',
            'command'     => "/usr/bin/test $(date +\\%0H) -eq 0 && /usr/local/sbin/mongodbbackup.sh",
            'environment' => ['TZ=Europe/Brussels', 'MAILTO=infra+cron@publiq.be'],
            'user'        => 'root',
            'hour'        => '*',
            'minute'      => '30'
          ) }
        end
      end

      context "with lvm => true, volume_group => myvg, backup_schedule => hourly and volume_size => 10G" do
        let(:params) { {
          'lvm'             => true,
          'volume_group'    => 'myvg',
          'volume_size'     => '10G',
          'backup_schedule' => 'hourly'
        } }

        context "with volume_group myvg present" do
          let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_cron('mongodb backup').with(
            'ensure'      => 'present',
            'command'     => '/usr/bin/true && /usr/local/sbin/mongodbbackup.sh',
            'environment' => ['TZ=Europe/Brussels', 'MAILTO=infra+cron@publiq.be'],
            'user'        => 'root',
            'hour'        => '*',
            'minute'      => '30'
          ) }

          it { is_expected.to contain_profiles__lvm__mount('mongodbbackup').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/backup/mongodb',
            'fs_type'      => 'ext4'
          ) }
        end
      end
    end
  end
end
