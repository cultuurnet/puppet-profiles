require 'spec_helper'

describe 'profiles::backup::server' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:facts) { facts }

      context "with public_key => 'xyz9876', hostname => 'foobar', physical_volumes => ['/dev/sdf', '/dev/sdg'] and backupdir => '/mnt'" do
        let(:params) { {
          'public_key' => 'xyz9876',
          'hostname'   => 'foobar',
          'physical_volumes' => ['/dev/sdf1', '/dev/sdg1'],
          'backupdir'        => '/mnt'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('borgbackup').with(
          'gid' => '1001'
        ) }

        it { is_expected.to contain_user('borgbackup').with(
          'uid'            => '1001',
          'home'           => '/home/borgbackup',
          'managehome'     => true,
          'gid'            => 'borgbackup',
          'purge_ssh_keys' => true
        ) }

        it { is_expected.to contain_ssh_authorized_key('backup').with(
          'key'     => 'xyz9876',
          'type'    => 'rsa',
          'options' => 'command="borg serve --restrict-to-path /mnt"'
        ) }

        it { is_expected.to contain_physical_volume('/dev/sdf1').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_physical_volume('/dev/sdg1').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_volume_group('backupvg').with(
          'ensure'           => 'present',
          'physical_volumes' => [ '/dev/sdf1', '/dev/sdg1']
        ) }

        it { is_expected.to contain_logical_volume('backup').with(
          'ensure'       => 'present',
          'volume_group' => 'backupvg',
          'size'         => '1G'
        ) }

        it { is_expected.to contain_filesystem('/dev/backupvg/backup').with(
          'ensure'  => 'present',
          'fs_type' => 'ext4'
        ) }

        it { is_expected.to contain_exec('create /mnt').with(
          'command' => 'install -o borgbackup -g borgbackup -d /mnt',
          'path'    => '/usr/bin:/usr/sbin:/bin',
          'unless'  => 'test -d /mnt'
        ) }

        it { is_expected.to contain_mount('/mnt').with(
          'ensure'  => 'mounted',
          'device'  => '/dev/backupvg/backup',
          'options' => 'defaults',
          'atboot'  => true,
          'fstype'  => 'ext4'
        ) }

        it { is_expected.to contain_file('/mnt').with(
          'ensure' => 'directory',
          'owner'  => 'borgbackup',
          'group'  => 'borgbackup'
        ) }

        it { is_expected.to contain_user('borgbackup').that_comes_before('Ssh_authorized_key[backup]') }
        it { is_expected.to contain_user('borgbackup').that_comes_before('Exec[create /mnt]') }
        it { is_expected.to contain_exec('create /mnt').that_comes_before('Mount[/mnt]') }
        it { is_expected.to contain_filesystem('/dev/backupvg/backup').that_comes_before('Mount[/mnt]') }
        it { is_expected.to contain_mount('/mnt').that_comes_before('File[/mnt]') }
      end

      context "with public_key => 'def456', public_key_type => 'dsa', hostname => 'baz', physical_volumes => '/dev/sdx', size => '100G' and backupdir => '/tmp/bla'" do
        let (:params) { {
          'public_key'       => 'def456',
          'public_key_type'  => 'dsa',
          'hostname'         => 'baz',
          'physical_volumes' => '/dev/sdx',
          'size'             => '100G',
          'backupdir'        => '/tmp/bla'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_ssh_authorized_key('backup').with(
          'key'     => 'def456',
          'type'    => 'dsa',
          'options' => 'command="borg serve --restrict-to-path /tmp/bla"'
        ) }

        it { is_expected.to contain_physical_volume('/dev/sdx').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_volume_group('backupvg').with(
          'ensure'           => 'present',
          'physical_volumes' => '/dev/sdx'
        ) }

        it { is_expected.to contain_logical_volume('backup').with(
          'ensure'       => 'present',
          'volume_group' => 'backupvg',
          'size'         => '100G'
        ) }

        it { is_expected.to contain_filesystem('/dev/backupvg/backup').with(
          'ensure'  => 'present',
          'fs_type' => 'ext4'
        ) }

        it { is_expected.to contain_exec('create /tmp/bla').with(
          'command' => 'install -o borgbackup -g borgbackup -d /tmp/bla',
          'path'    => '/usr/bin:/usr/sbin:/bin',
          'unless'  => 'test -d /tmp/bla'
        ) }

        it { is_expected.to contain_mount('/tmp/bla').with(
          'ensure'  => 'mounted',
          'device'  => '/dev/backupvg/backup',
          'options' => 'defaults',
          'atboot'  => true,
          'fstype'  => 'ext4'
        ) }

        it { is_expected.to contain_file('/tmp/bla').with(
          'ensure' => 'directory',
          'owner'  => 'borgbackup',
          'group'  => 'borgbackup'
        ) }

        it { is_expected.to contain_user('borgbackup').that_comes_before('Exec[create /tmp/bla]') }
        it { is_expected.to contain_exec('create /tmp/bla').that_comes_before('Mount[/tmp/bla]') }
        it { is_expected.to contain_filesystem('/dev/backupvg/backup').that_comes_before('Mount[/tmp/bla]') }
        it { is_expected.to contain_mount('/tmp/bla').that_comes_before('File[/tmp/bla]') }
      end

      context "without parameters" do
        let(:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'hostname'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'public_key'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'physical_volumes'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'backupdir'/) }
      end
    end
  end
end
