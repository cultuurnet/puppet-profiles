describe 'profiles::vault::backup' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault::backup').with(
          'lvm'            => false,
          'volume_group'   => nil,
          'volume_size'    => nil,
          'retention_days' => 7
        ) }

        it { is_expected.to contain_file('/data') }
        it { is_expected.to contain_file('/data/backup') }
        it { is_expected.to contain_file('/data/backup/vault').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/data/backup/vault/current').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/data/backup/vault/archive').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('vaultbackup').with(
          'ensure' => 'file',
          'path'   => '/usr/local/bin/vaultbackup',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
          'source' => 'puppet:///modules/profiles/vault/vaultbackup'
        ) }

        it { is_expected.to contain_cron('backup vault').with(
          'command'     => '/usr/local/bin/vaultbackup',
          'environment' => ['MAILTO=infra+cron@publiq.be'],
          'user'        => 'root',
          'hour'        => '0',
          'minute'      => '15',
        ) }

        it { is_expected.to contain_cron('Cleanup old vault backups').with(
          'command'     => '/usr/bin/find /data/backup/vault/archive -type f -mtime +6 -delete',
          'environment' => ['MAILTO=infra+cron@publiq.be'],
          'user'        => 'root',
          'hour'        => '2',
          'minute'      => '15'
        ) }

        it { is_expected.to contain_file('/data/backup/vault').that_requires('File[/data/backup]') }
        it { is_expected.to contain_file('/data/backup/vault/current').that_requires('File[/data/backup/vault]') }
        it { is_expected.to contain_file('/data/backup/vault/archive').that_requires('File[/data/backup/vault]') }
        it { is_expected.to contain_cron('Cleanup old vault backups').that_requires('File[/data/backup/vault/archive]') }
        it { is_expected.to contain_cron('backup vault').that_requires('File[vaultbackup]') }
      end

      context "with lvm => true, volume_group => backupvg, volume_size => 20G and retention_days => 10" do
        let(:params) { {
          'lvm'            => true,
          'volume_group'   => 'backupvg',
          'volume_size'    => '20G',
          'retention_days' => 10
        } }

        context "with volume_group backupvg present" do
          let(:pre_condition) {  'volume_group { "backupvg": ensure => "present" }' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__lvm__mount('vaultbackup').with(
            'volume_group' => 'backupvg',
            'size'         => '20G',
            'mountpoint'   => '/data/backup/vault',
            'fs_type'      => 'ext4'
          ) }

          it { is_expected.to contain_cron('Cleanup old vault backups').with(
            'command'  => '/usr/bin/find /data/backup/vault/archive -type f -mtime +9 -delete',
            'user'     => 'root',
            'hour'     => '2',
            'minute'   => '15',
          ) }
        end
      end

      context "with lvm => true, volume_group => myvg and volume_size => 10G" do
        let(:params) { {
          'lvm'          => true,
          'volume_group' => 'myvg',
          'volume_size'  => '10G'
        } }

        context "with volume_group myvg present" do
          let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__lvm__mount('vaultbackup').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/backup/vault',
            'fs_type'      => 'ext4'
          ) }
        end
      end
    end
  end
end
