describe 'profiles::lvm::mount' do
  context 'with title => foo' do
    let(:title) { 'foo' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "with volume_group datavg present" do
          let(:pre_condition) { 'volume_group { "datavg": ensure => "present" }' }

          context 'with volume_group => datavg, size => 1G and mountpoint => /data/foo' do
            let(:params) { {
              'volume_group' => 'datavg',
              'size'         => '1G',
              'mountpoint'   => '/data/foo'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_profiles__lvm__mount('foo').with(
              'volume_group'  => 'datavg',
              'size'          => '1G',
              'fs_type'       => 'ext4',
              'fs_options'    => nil,
              'mount_options' => nil,
              'owner'         => 'root',
              'group'         => 'root'
            ) }

            it { is_expected.to contain_logical_volume('foo').with(
              'ensure'          => 'present',
              'volume_group'    => 'datavg',
              'size'            => '1G',
              'size_is_minsize' => true
            ) }

            it { is_expected.to contain_filesystem('/dev/datavg/foo').with(
              'ensure'  => 'present',
              'fs_type' => 'ext4',
              'options' => nil
            ) }

            it { is_expected.to contain_file('/data') }
            it { is_expected.not_to contain_file('/data/backup') }

            it { is_expected.to contain_file('/data/foo').with(
              'ensure' => 'directory',
              'owner'  => 'root',
              'group'  => 'root'
            ) }

            it { is_expected.to contain_mount('/data/foo').with(
              'ensure'  => 'mounted',
              'device'  => '/dev/datavg/foo',
              'fstype'  => 'ext4',
              'options' => nil,
              'atboot'  => true
            ) }

            it { is_expected.to contain_exec('/data/foo ownership').with(
              'command'   => 'chown root:root /data/foo',
              'logoutput' => 'on_failure',
              'path'      => ['/usr/bin', '/bin'],
              'onlyif'    => "test 'root:root' != $(stat -c '%U:%G' /data/foo)"
            ) }

            it { is_expected.to contain_logical_volume('foo').that_requires('Volume_group[datavg]') }
            it { is_expected.to contain_logical_volume('foo').that_comes_before('Filesystem[/dev/datavg/foo]') }
            it { is_expected.to contain_filesystem('/dev/datavg/foo').that_comes_before('Mount[/data/foo]') }
            it { is_expected.to contain_file('/data').that_comes_before('File[/data/foo]') }
            it { is_expected.to contain_file('/data/foo').that_comes_before('Mount[/data/foo]') }
            it { is_expected.to contain_mount('/data/foo').that_comes_before('Exec[/data/foo ownership]') }
          end
        end

        context "with volume_group foovg present" do
          let(:pre_condition) { 'volume_group { "foovg": ensure => "present" }' }

          context 'with volume_group => foovg, size => 10G, owner => ubuntu, group => ubuntu, mountpoint => /data/foo/bar/baz, fs_type => ext3, fs_options => "-b 4096" and mount_options => ro' do
            let(:params) { {
              'volume_group' => 'foovg',
              'size'         => '10G',
              'mountpoint'   => '/data/foo/bar/baz',
              'fs_type'       => 'ext3',
              'fs_options'    => '-b 4096',
              'mount_options' => 'ro',
              'owner'         => 'ubuntu',
              'group'         => 'ubuntu'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_group('ubuntu') }
            it { is_expected.to contain_user('ubuntu') }

            it { is_expected.to contain_logical_volume('foo').with(
              'ensure'          => 'present',
              'volume_group'    => 'foovg',
              'size'            => '10G',
              'size_is_minsize' => true
            ) }

            it { is_expected.to contain_filesystem('/dev/foovg/foo').with(
              'ensure'  => 'present',
              'fs_type' => 'ext3',
              'options' => '-b 4096'
            ) }

            it { is_expected.to contain_file('/data/foo').with(
              'ensure' => 'directory',
              'owner'  => 'ubuntu',
              'group'  => 'ubuntu'
            ) }

            it { is_expected.to contain_file('/data/foo/bar').with(
              'ensure' => 'directory',
              'owner'  => 'ubuntu',
              'group'  => 'ubuntu'
            ) }

            it { is_expected.to contain_file('/data/foo/bar/baz').with(
              'ensure' => 'directory',
              'owner'  => 'ubuntu',
              'group'  => 'ubuntu'
            ) }

            it { is_expected.to contain_mount('/data/foo/bar/baz').with(
              'ensure'  => 'mounted',
              'device'  => '/dev/foovg/foo',
              'fstype'  => 'ext3',
              'options' => 'ro',
              'atboot'  => true
            ) }

            it { is_expected.to contain_exec('/data/foo/bar/baz ownership').with(
              'command'   => 'chown ubuntu:ubuntu /data/foo/bar/baz',
              'logoutput' => 'on_failure',
              'path'      => ['/usr/bin', '/bin'],
              'onlyif'    => "test 'ubuntu:ubuntu' != $(stat -c '%U:%G' /data/foo/bar/baz)"
            ) }

            it { is_expected.to contain_file('/data/foo').that_requires('Group[ubuntu]') }
            it { is_expected.to contain_file('/data/foo').that_requires('User[ubuntu]') }
            it { is_expected.to contain_file('/data/foo/bar').that_requires('Group[ubuntu]') }
            it { is_expected.to contain_file('/data/foo/bar').that_requires('User[ubuntu]') }
            it { is_expected.to contain_file('/data/foo/bar/baz').that_requires('Group[ubuntu]') }
            it { is_expected.to contain_file('/data/foo/bar/baz').that_requires('User[ubuntu]') }
            it { is_expected.to contain_file('/data/foo/bar/baz').that_comes_before('Mount[/data/foo/bar/baz]') }
          end
        end

        context 'without parameters' do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'volume_group'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'size'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'mountpoint'/) }
        end
      end
    end
  end

  context 'with title => bar' do
    let(:title) { 'bar' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "with volume_group myvg present" do
          let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

          context 'with volume_group => myvg, size => 5G and mountpoint => /data/backup/mydata' do
            let(:params) { {
              'volume_group' => 'myvg',
              'size'         => '5G',
              'mountpoint'   => '/data/backup/mydata'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_file('/data') }
            it { is_expected.to contain_file('/data/backup') }

            it { is_expected.to contain_logical_volume('bar').with(
              'ensure'          => 'present',
              'volume_group'    => 'myvg',
              'size'            => '5G',
              'size_is_minsize' => true
            ) }

            it { is_expected.to contain_filesystem('/dev/myvg/bar').with(
              'ensure'  => 'present',
              'fs_type' => 'ext4',
              'options' => nil
            ) }

            it { is_expected.to contain_file('/data/backup/mydata').with(
              'ensure' => 'directory',
              'owner'  => 'root',
              'group'  => 'root'
            ) }

            it { is_expected.to contain_mount('/data/backup/mydata').with(
              'ensure'  => 'mounted',
              'device'  => '/dev/myvg/bar',
              'fstype'  => 'ext4',
              'options' => nil,
              'atboot'  => true
            ) }

            it { is_expected.to contain_exec('/data/backup/mydata ownership').with(
              'command'   => 'chown root:root /data/backup/mydata',
              'logoutput' => 'on_failure',
              'path'      => ['/usr/bin', '/bin'],
              'onlyif'    => "test 'root:root' != $(stat -c '%U:%G' /data/backup/mydata)"
            ) }

            it { is_expected.to contain_logical_volume('bar').that_requires('Volume_group[myvg]') }
            it { is_expected.to contain_logical_volume('bar').that_comes_before('Filesystem[/dev/myvg/bar]') }
            it { is_expected.to contain_filesystem('/dev/myvg/bar').that_comes_before('Mount[/data/backup/mydata]') }
            it { is_expected.to contain_file('/data/backup/mydata').that_comes_before('Mount[/data/backup/mydata]') }
            it { is_expected.to contain_mount('/data/backup/mydata').that_comes_before('Exec[/data/backup/mydata ownership]') }
          end
        end
      end
    end
  end
end
