describe 'profiles::redis' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::redis').with(
          'version'          => 'installed',
          'persist_data'     => true,
          'lvm'              => false,
          'volume_group'     => nil,
          'volume_size'      => nil,
          'maxmemory'        => nil,
          'maxmemory_policy' => nil
        ) }

        it { is_expected.to contain_group('redis') }
        it { is_expected.to contain_user('redis') }

        it { is_expected.to contain_firewall('400 accept redis traffic') }

        it { is_expected.to contain_class('redis').with(
          'package_ensure'   => 'installed',
          'workdir'          => '/var/lib/redis',
          'save_db_to_disk'  => true,
          'workdir_mode'     => '0755',
          'service_manage'   => false,
          'maxmemory'        => nil,
          'maxmemory_policy' => nil
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

      context "with volume_group datavg present" do
        let(:pre_condition) { 'volume_group { "datavg": ensure => "present" }' }

        context "with version => 1.2.3, lvm => true, volume_group => datavg, volume_size => 20G, maxmemory => 200mb and maxmemory_policy => noeviction" do
          let(:params) { {
            'version'          => '1.2.3',
            'lvm'              => true,
            'volume_group'     => 'datavg',
            'volume_size'      => '20G',
            'maxmemory'        => '200mb',
            'maxmemory_policy' => 'noeviction'
          } }

          it { is_expected.to contain_class('redis').with(
            'package_ensure'   => '1.2.3',
            'maxmemory'        => '200mb',
            'maxmemory_policy' => 'noeviction'
          ) }

          it { is_expected.to contain_profiles__lvm__mount('redisdata').with(
            'volume_group' => 'datavg',
            'size'         => '20G',
            'fs_type'      => 'ext4',
            'mountpoint'   => '/data/redis',
            'owner'        => 'redis',
            'group'        => 'redis'
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

      context "with volume_group myvg present" do
        let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

        context "with lvm => true, volume_group => myvg and volume_size => 10G" do
          let(:params) { {
            'lvm'          => true,
            'volume_group' => 'myvg',
            'volume_size'  => '10G'
          } }

          it { is_expected.to contain_profiles__lvm__mount('redisdata').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/redis',
            'owner'        => 'redis',
            'group'        => 'redis'
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
