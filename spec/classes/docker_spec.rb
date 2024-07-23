describe 'profiles::docker' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('docker') }

        it { is_expected.to contain_class('profiles::docker').with(
          'experimental'   => false,
          'schedule_prune' => false,
          'lvm'            => false,
          'volume_group'   => nil,
          'volume_size'    => nil
        ) }

        it { is_expected.to contain_file('/var/lib/docker').with(
          'ensure' => 'directory'
        ) }

        it { is_expected.to contain_class('docker').with(
          'use_upstream_package_source' => false,
          'extra_parameters'            => [ '--experimental=false'],
          'docker_users'                => []
        ) }

        it { is_expected.to_not contain_profiles__lvm__mount('dockerdata') }
        it { is_expected.to_not contain_mount('/var/lib/docker') }

        it { is_expected.to_not contain_package('qemu-user-static') }

        it { is_expected.to contain_cron('docker system prune').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_apt__source('docker').that_comes_before('Class[docker]') }
        it { is_expected.to contain_file('/var/lib/docker').that_comes_before('Class[docker]') }
      end

      context "with experimental => true, lvm => true, volume_group => dockervg, volume_size => 5G and schedule_prune => true" do
        let(:params) { {
          'experimental'   => true,
          'schedule_prune' => true,
          'lvm'            => true,
          'volume_group'   => 'dockervg',
          'volume_size'    => '5G'
        } }

        context "with volume_group dockervg present" do
          let(:pre_condition) { 'volume_group { "dockervg": ensure => "present" }' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__lvm__mount('dockerdata').with(
            'volume_group' => 'dockervg',
            'size'         => '5G',
            'mountpoint'   => '/data/docker',
            'fs_type'      => 'ext4',
            'owner'        => 'root',
            'group'        => 'root'
          ) }

          it { is_expected.to contain_mount('/var/lib/docker').with(
            'ensure'  => 'mounted',
            'device'  => '/data/docker',
            'fstype'  => 'none',
            'options' => 'rw,bind'
          ) }

          it { is_expected.to contain_file('/var/lib/docker').with(
            'ensure' => 'directory'
          ) }

          it { is_expected.to contain_class('docker').with(
            'use_upstream_package_source' => false,
            'extra_parameters'            => [ '--experimental=true'],
            'docker_users'                => []
          ) }

          it { is_expected.to contain_package('qemu-user-static') }

          it { is_expected.to contain_cron('docker system prune').with(
            'ensure'      => 'present',
            'command'     => '/usr/bin/docker system prune -f -a --volumes',
            'environment' => ['MAILTO=infra+cron@publiq.be'],
            'hour'        => '3',
            'minute'      => '30',
            'weekday'     => '0',
          ) }

          it { is_expected.to contain_mount('/var/lib/docker').that_requires('Profiles::Lvm::Mount[dockerdata]') }
          it { is_expected.to contain_mount('/var/lib/docker').that_requires('File[/var/lib/docker]') }
          it { is_expected.to contain_mount('/var/lib/docker').that_comes_before('Class[docker]') }
          it { is_expected.to contain_cron('docker system prune').that_requires('Class[docker]') }
        end
      end

      context "with lvm => true, volume_group => myvg and volume_size => 10G" do
        let(:params) { {
          'lvm'            => true,
          'volume_group'   => 'myvg',
          'volume_size'    => '10G'
        } }

        context "with volume_group myvg present" do
          let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__lvm__mount('dockerdata').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/docker',
            'fs_type'      => 'ext4',
            'owner'        => 'root',
            'group'        => 'root'
          ) }

          it { is_expected.to contain_mount('/var/lib/docker').with(
            'ensure'  => 'mounted',
            'device'  => '/data/docker',
            'fstype'  => 'none',
            'options' => 'rw,bind'
          ) }

          it { is_expected.to contain_file('/var/lib/docker').with(
            'ensure' => 'directory'
          ) }

          it { is_expected.to contain_mount('/var/lib/docker').that_requires('Profiles::Lvm::Mount[dockerdata]') }
          it { is_expected.to contain_mount('/var/lib/docker').that_requires('File[/var/lib/docker]') }
          it { is_expected.to contain_mount('/var/lib/docker').that_comes_before('Class[docker]') }
          it { is_expected.to contain_cron('docker system prune').that_requires('Class[docker]') }
        end
      end
    end
  end
end
