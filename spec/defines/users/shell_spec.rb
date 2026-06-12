describe 'profiles::users::shell' do
  context 'with title => publiq-first' do
    let(:title) { 'publiq-first' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'with uid => 5500' do
          let(:params) { {
            'uid' => 5500
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__users__shell('publiq-first').with(
            'uid'    => 5500,
            'active' => false,
            'admin'  => false
          ) }

          it { is_expected.to contain_group('publiq-first').with(
            'gid'    => '5500',
            'ensure' => 'absent'
          ) }

          it { is_expected.to contain_user('publiq-first').with(
            'ensure'         => 'absent',
            'gid'            => 'publiq-first',
            'groups'         => [],
            'home'           => '/home/publiq-first',
            'managehome'     => true,
            'purge_ssh_keys' => true,
            'shell'          => '/bin/bash',
            'uid'            => 5500
          ) }
        end

        context 'with uid => 6000, active => true, admin => true' do
          let(:params) { {
            'uid'    => 6000,
            'active' => true,
            'admin'  => true
          } }

          it { is_expected.to contain_group('publiq-first').with(
            'gid'    => '6000',
            'ensure' => 'present'
          ) }

          it { is_expected.to contain_user('publiq-first').with(
            'ensure'         => 'present',
            'gid'            => 'publiq-first',
            'groups'         => ['sudo'],
            'home'           => '/home/publiq-first',
            'managehome'     => true,
            'purge_ssh_keys' => true,
            'shell'          => '/bin/bash',
            'uid'            => 6000
          ) }
        end

        context 'with uid => 7000, active => false' do
          let(:params) { {
            'uid'    => 7000,
            'active' => false
          } }

          it { is_expected.to contain_group('publiq-first').with(
            'gid'    => '7000',
            'ensure' => 'absent'
          ) }

          it { is_expected.to contain_user('publiq-first').with(
            'ensure'         => 'absent',
            'gid'            => 'publiq-first',
            'groups'         => [],
            'home'           => '/home/publiq-first',
            'managehome'     => true,
            'purge_ssh_keys' => true,
            'shell'          => '/bin/bash',
            'uid'            => 7000
          ) }
        end

        context 'with uid => 4000' do
          let(:params) { {
            'uid' => 4000
          } }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /parameter 'uid' expects an Integer\[5000\] value/) }
        end

        context 'without parameters' do
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'uid'/) }
        end
      end
    end
  end

  context 'with title => Café Hôtel!' do
    let(:title) { 'Café Hôtel!' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'with uid => 5600, active => true' do
          let(:params) { {
            'uid'    => 5600,
            'active' => true
          } }

          it { is_expected.to contain_group('cafe-hotel').with(
            'gid'    => '5600',
            'ensure' => 'present'
          ) }

          it { is_expected.to contain_user('cafe-hotel').with(
            'ensure'         => 'present',
            'gid'            => 'cafe-hotel',
            'groups'         => [],
            'home'           => '/home/cafe-hotel',
            'managehome'     => true,
            'purge_ssh_keys' => true,
            'shell'          => '/bin/bash',
            'uid'            => 5600
          ) }
        end
      end
    end
  end
end
