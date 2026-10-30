describe 'profiles::uitpas::cid_logs' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) { { 'hostname' => 'cidlogs.example.com', 'aliases' => [] } }
      let(:pre_condition) { 'include profiles::apache, profiles::logstash, profiles::lvm' }
      let(:hiera_config) { 'spec/support/hiera/cid_logs.yaml' }

      context 'without LVM' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_profiles__lvm__mount('cidlogsdata') }
        it { is_expected.not_to contain_mount('/data/cidlogs-ebs') }
      end

      context 'with LVM enabled' do
        let(:params) { super().merge({ 'lvm' => true, 'volume_group' => 'datavg', 'volume_size' => '49G', 'mountpoint' => '/data/cidlogs-ebs' }) }
        let(:pre_condition) { <<~PUPPET
          include profiles::apache, profiles::logstash
          class { 'profiles::lvm':
            volume_groups => { 'datavg' => { 'physical_volumes' => ['/dev/xvdb'] } }
          }
        PUPPET
        }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_profiles__lvm__mount('cidlogsdata').with(
          'volume_group' => 'datavg',
          'size' => '49G',
          'mountpoint' => '/data/cidlogs-ebs',
          'fs_type' => 'ext4',
          'owner' => 'logstash',
          'group' => 'logstash'
        ) }
        it { is_expected.to contain_mount('/data/cidlogs-ebs').with(
          'ensure' => 'mounted',
          'device' => '/dev/datavg/cidlogsdata',
          'fstype' => 'ext4',
          'atboot' => true
        ) }
        it { is_expected.to contain_logical_volume('cidlogsdata').with('size' => '49G', 'size_is_minsize' => true) }
        it { is_expected.to contain_file('/data/cidlogs').with('ensure' => 'directory') }
      end

      context 'with LVM mounted at the default data directory' do
        let(:params) { super().merge({ 'lvm' => true, 'volume_group' => 'datavg', 'volume_size' => '49G' }) }
        let(:pre_condition) { <<~PUPPET
          include profiles::apache, profiles::logstash
          class { 'profiles::lvm':
            volume_groups => { 'datavg' => { 'physical_volumes' => ['/dev/xvdb'] } }
          }
        PUPPET
        }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_mount('/data/cidlogs').with('device' => '/dev/datavg/cidlogsdata') }
        it { is_expected.not_to contain_mount('/data/cidlogs-ebs') }
        it { is_expected.to contain_profiles__lvm__mount('cidlogsdata').that_comes_before('Service[logstash]') }
      end

      context 'with LVM explicitly disabled and no volume group' do
        let(:params) { super().merge({ 'lvm' => false }) }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_physical_volume('/dev/xvdb') }
        it { is_expected.not_to contain_profiles__lvm__mount('cidlogsdata') }
        it { is_expected.not_to contain_mount('/data/cidlogs-ebs') }
      end

      context 'with LVM enabled but no volume group or size' do
        let(:params) { super().merge({ 'lvm' => true }) }

        it { is_expected.to compile.and_raise_error(/expects a value for both 'volume_group' and 'volume_size'/) }
      end
    end
  end
end
