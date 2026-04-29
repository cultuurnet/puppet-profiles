describe 'profiles::ssh::sshd_config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with title => foo' do
        let(:title) { 'foo' }

        context 'with value => true' do
          let(:params) { {
            'value' => true
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__ssh__sshd_config('foo').with(
            'ensure' => 'present',
            'value'  => true
          ) }

          it { is_expected.to contain_augeas('Sshd_config foo').with(
            'lens'    => 'Sshd.lns',
            'incl'    => '/etc/ssh/sshd_config',
            'context' => '/files/etc/ssh/sshd_config',
            'changes' => "set foo 'true'"
          ) }
        end

        context 'with ensure => absent' do
          let(:params) { {
            'ensure' => 'absent'
          } }

          it { is_expected.to contain_augeas('Sshd_config foo').with(
            'lens'    => 'Sshd.lns',
            'incl'    => '/etc/ssh/sshd_config',
            'context' => '/files/etc/ssh/sshd_config',
            'changes' => "rm foo"
          ) }
        end

        context 'with value => bar' do
          let(:params) { {
            'value' => 'bar'
          } }

          it { is_expected.to contain_augeas('Sshd_config foo').with(
            'lens'    => 'Sshd.lns',
            'incl'    => '/etc/ssh/sshd_config',
            'context' => '/files/etc/ssh/sshd_config',
            'changes' => "set foo 'bar'"
          ) }
        end
      end

      context 'with title => PermitRootLogin' do
        let(:title) { 'PermitRootLogin' }

        context 'with value => no' do
          let(:params) { {
            'value' => 'no'
          } }

          it { is_expected.to contain_augeas('Sshd_config PermitRootLogin').with(
            'lens'    => 'Sshd.lns',
            'incl'    => '/etc/ssh/sshd_config',
            'context' => '/files/etc/ssh/sshd_config',
            'changes' => "set PermitRootLogin 'no'"
          ) }
        end

        context 'without parameters' do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /Value cannot be nil when ensure is 'present'/) }
        end
      end
    end
  end
end
