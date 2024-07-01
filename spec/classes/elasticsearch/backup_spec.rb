describe 'profiles::elasticsearch::backup' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::elasticsearch::backup').with(
          'lvm'            => false,
          'volume_group'   => nil,
          'volume_size'    => nil,
          'time'           => [0, 0],
          'retention_days' => 7
        ) }

        it { is_expected.to contain_class('profiles::elasticdump') }

        it { is_expected.to contain_file('/data') }
        it { is_expected.to contain_file('/data/backup') }
        it { is_expected.to contain_file('/data/backup/elasticsearch').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/data/backup/elasticsearch/current').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/data/backup/elasticsearch/archive').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/usr/local/sbin/elasticsearchbackup.sh').with(
          'ensure' => 'file',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/usr/local/sbin/elasticsearchbackup.sh').with_content(/^retention=6$/) }

        it { is_expected.to contain_cron('elasticsearch-backup').with(
          'command'     => '/usr/local/sbin/elasticsearchbackup.sh',
          'environment' => ['MAILTO=infra@publiq.be'],
          'user'        => 'root',
          'hour'        => 0,
          'minute'      => 0
        ) }

        it { is_expected.to contain_file('/data/backup').that_requires('File[/data]') }
        it { is_expected.to contain_file('/data/backup/elasticsearch').that_requires('File[/data/backup]') }
        it { is_expected.to contain_file('/data/backup/elasticsearch/current').that_requires('File[/data/backup/elasticsearch]') }
        it { is_expected.to contain_file('/data/backup/elasticsearch/archive').that_requires('File[/data/backup/elasticsearch]') }
        it { is_expected.to contain_cron('elasticsearch-backup').that_requires('File[/data/backup/elasticsearch/current]') }
        it { is_expected.to contain_cron('elasticsearch-backup').that_requires('File[/data/backup/elasticsearch/archive]') }
        it { is_expected.to contain_cron('elasticsearch-backup').that_requires('File[/usr/local/sbin/elasticsearchbackup.sh]') }
      end

      context "with lvm => true, volume_group => backupvg, volume_size => 20G, time => [1, 5] and retention_days => 10" do
        let(:params) { {
          'lvm'            => true,
          'volume_group'   => 'backupvg',
          'volume_size'    => '20G',
          'time'           => [1, 5],
          'retention_days' => 10
        } }

        context "with volume_group backupvg present" do
          let(:pre_condition) { 'volume_group { "backupvg": ensure => "present" }' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::elasticdump') }

          it { is_expected.to contain_profiles__lvm__mount('elasticsearchbackup').with(
            'volume_group' => 'backupvg',
            'size'         => '20G',
            'mountpoint'   => '/data/backup/elasticsearch',
            'fs_type'      => 'ext4'
          ) }

          it { is_expected.to contain_file('/data/backup/elasticsearch/current').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755'
          ) }

          it { is_expected.to contain_file('/data/backup/elasticsearch/archive').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755'
          ) }

          it { is_expected.to contain_file('/usr/local/sbin/elasticsearchbackup.sh').with_content(/^retention=9$/) }

          it { is_expected.to contain_cron('elasticsearch-backup').with(
            'command'     => '/usr/local/sbin/elasticsearchbackup.sh',
            'environment' => ['MAILTO=infra@publiq.be'],
            'user'        => 'root',
            'hour'        => 1,
            'minute'      => 5
          ) }

          it { is_expected.to contain_file('/data/backup/elasticsearch/current').that_requires('Profiles::Lvm::Mount[elasticsearchbackup]') }
          it { is_expected.to contain_file('/data/backup/elasticsearch/archive').that_requires('Profiles::Lvm::Mount[elasticsearchbackup]') }
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

          it { is_expected.to contain_class('profiles::elasticdump') }

          it { is_expected.to contain_profiles__lvm__mount('elasticsearchbackup').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/backup/elasticsearch',
            'fs_type'      => 'ext4'
          ) }
        end
      end
    end
  end
end
