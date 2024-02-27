describe 'profiles::glassfish::domain' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "title foobar-api" do
        let(:title) { 'foobar-api' }

        context 'without parameters' do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__glassfish__domain('foobar-api').with(
            'ensure'   => 'present',
            'portbase' => 4800
          ) }

          it { is_expected.to contain_class('profiles::glassfish') }

          it { is_expected.to contain_group('glassfish') }
          it { is_expected.to contain_user('glassfish') }

          it { is_expected.to contain_domain('foobar-api').with(
            'ensure'            => 'present',
            'user'              => 'glassfish',
            'asadminuser'       => 'admin',
            'passwordfile'      => '/home/glassfish/asadmin.pass',
            'portbase'          => '4800',
            'startoncreate'     => false,
            'enablesecureadmin' => false,
            'template'          => nil
          ) }

          it { is_expected.to contain_firewall('400 accept glassfish domain foobar-api traffic').with(
            'proto'  => 'tcp',
            'dport'  => '4880',
            'action' => 'accept'
          ) }

          it { is_expected.to contain_profiles__glassfish__domain__service('foobar-api').with(
            'status' => 'running'
          ) }

          it { is_expected.to contain_domain('foobar-api').that_requires('Group[glassfish]') }
          it { is_expected.to contain_domain('foobar-api').that_requires('User[glassfish]') }
          it { is_expected.to contain_profiles__glassfish__domain__service('foobar-api').that_requires('Domain[foobar-api]') }
        end

        context 'with portbase => 14800 and status => stopped' do
          let(:params) { {
            'portbase' => 14800,
            'status'   => 'stopped'
          } }

          it { is_expected.to contain_domain('foobar-api').with(
            'ensure'            => 'present',
            'user'              => 'glassfish',
            'asadminuser'       => 'admin',
            'passwordfile'      => '/home/glassfish/asadmin.pass',
            'portbase'          => '14800',
            'startoncreate'     => false,
            'enablesecureadmin' => false,
            'template'          => nil
          ) }

          it { is_expected.to contain_firewall('400 accept glassfish domain foobar-api traffic').with(
            'proto'  => 'tcp',
            'dport'  => '14880',
            'action' => 'accept'
          ) }

          it { is_expected.to contain_profiles__glassfish__domain__service('foobar-api').with(
            'status' => 'stopped'
          ) }
        end
      end

      context "title baz-api" do
        let(:title) { 'baz-api' }

        context 'without parameters' do
          let(:params) { {} }

          it { is_expected.to contain_domain('baz-api').with(
            'ensure'            => 'present',
            'user'              => 'glassfish',
            'asadminuser'       => 'admin',
            'passwordfile'      => '/home/glassfish/asadmin.pass',
            'portbase'          => '4800',
            'startoncreate'     => false,
            'enablesecureadmin' => false,
            'template'          => nil
          ) }

          it { is_expected.to contain_profiles__glassfish__domain__service('baz-api').with(
            'status' => 'running'
          ) }
        end

        context 'with ensure => absent' do
          let(:params) { {
            'ensure' => 'absent'
          } }

          it { is_expected.to contain_domain('baz-api').with(
            'ensure' => 'absent'
          ) }

          it { is_expected.to contain_profiles__glassfish__domain__service('baz-api').with(
            'ensure' => 'absent'
          ) }
        end
      end
    end
  end
end
