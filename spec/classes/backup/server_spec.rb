describe 'profiles::backup::server' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with public_key => 'xyz9876', hostname => 'foobar'" do
        let(:params) { {
          'public_key' => 'xyz9876',
          'hostname'   => 'foobar'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('borgbackup') }

        it { is_expected.to contain_user('borgbackup') }

        it { is_expected.to contain_ssh_authorized_key('backup').with(
          'key'     => 'xyz9876',
          'type'    => 'rsa',
          'options' => 'command="borg serve --restrict-to-path /data/borgbackup"'
        ) }

        it { is_expected.to contain_file('/data/borgbackup').with(
          'ensure' => 'directory',
          'owner'  => 'borgbackup',
          'group'  => 'borgbackup'
        ) }

        it { is_expected.to contain_user('borgbackup').that_comes_before('Ssh_authorized_key[backup]') }
        it { is_expected.to contain_file('/data/borgbackup') }
      end

      context "with public_key => 'def456', public_key_type => 'dsa', hostname => 'baz', lvm => true, volume_group => 'backupvg', volume_size => '100G' and backupdir => '/data/backuptest'" do
        let(:params) { {
          'public_key'       => 'def456',
          'public_key_type'  => 'dsa',
          'hostname'         => 'baz',
          'lvm'              => true,
          'volume_group'     => 'backupvg',
          'volume_size'      => '100G',
          'backupdir'        => '/data/backuptest'
        } }

        context "with volume_group backupvg present" do
          let(:pre_condition) { 'volume_group { "backupvg": ensure => "present" }' }


          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_ssh_authorized_key('backup').with(
            'key'     => 'def456',
            'type'    => 'dsa',
            'options' => 'command="borg serve --restrict-to-path /data/backuptest"'
          ) }

          it { is_expected.to contain_file('/data/backuptest').with(
            'ensure' => 'directory',
            'owner'  => 'borgbackup',
            'group'  => 'borgbackup'
          ) }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'hostname'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'public_key'/) }
      end
    end
  end
end
