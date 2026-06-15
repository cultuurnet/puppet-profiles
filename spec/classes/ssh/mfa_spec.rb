describe 'profiles::ssh::mfa' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) do
        [
          "user { 'publiq-first-user': ensure => present }",
          "user { 'publiq-inactive-user': ensure => absent }"
        ]
      end
      let(:params) do
        {
          'enabled'              => true,
          'authorized_keys'      => {
            'Publiq First User'    => { 'tags' => ['publiq', 'bastion'], 'admin' => true },
            'Publiq Missing User'  => { 'tags' => 'bastion' },
            'Publiq Inactive User' => { 'tags' => 'bastion', 'active' => false },
            'Publiq Other User'    => { 'tags' => 'other' }
          },
          'authorized_keys_tags' => 'bastion',
          'mfa_directory'        => File.expand_path('../../support/mfa', __dir__)
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::ssh::mfa').with(
        'enabled'              => true,
        'authorized_keys_tags' => 'bastion',
        'bypass_ips'           => ['194.78.13.220']
      ) }

      it { is_expected.to contain_package('libpam-google-authenticator').with(
        'ensure' => 'installed'
      ) }

      it { is_expected.to contain_group('mfa_users').with_ensure('present') }
      it { is_expected.to contain_user('publiq-first-user').with_groups(['sudo', 'mfa_users']) }
      it { is_expected.to contain_user('publiq-inactive-user').with_groups([]) }

      it { is_expected.to contain_file('/etc/pam.d/sshd').with(
        'ensure' => 'file',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644'
      ).without_content(%r{@include common-auth}) }

      it { is_expected.to contain_file('/etc/pam.d/sshd').without_content(%r{pam_succeed_if\.so}) }
      it { is_expected.to contain_file('/etc/pam.d/sshd').with_content(%r{pam_google_authenticator\.so nullok}) }
      it { is_expected.to contain_file('/etc/pam.d/sshd').with_content(%r{auth required pam_permit\.so}) }
      it { is_expected.to contain_file('/etc/pam.d/sshd').that_requires('Package[libpam-google-authenticator]') }

      it { is_expected.to contain_profiles__ssh__sshd_config('UsePAM').with_value('yes') }
      it { is_expected.to contain_profiles__ssh__sshd_config('ChallengeResponseAuthentication').with_value('yes') }
      it { is_expected.to contain_profiles__ssh__sshd_config('AuthenticationMethods').with_ensure('absent') }
      it { is_expected.to contain_file('/etc/ssh/sshd_config.d/publiq-mfa.conf').with(
        'ensure' => 'file',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644'
      ).with_content(%r{Match Group mfa_users Address \*,!194\.78\.13\.220}) }

      it { is_expected.to contain_file('/etc/ssh/sshd_config.d/publiq-mfa.conf').with_content(%r{AuthenticationMethods publickey,keyboard-interactive:pam}) }
      it { is_expected.to contain_file('/etc/ssh/sshd_config.d/publiq-mfa.conf').with_content(%r{Match all}) }

      it { is_expected.to contain_file('/home/publiq-first-user/.google_authenticator').with(
        'ensure'    => 'file',
        'owner'     => 'publiq-first-user',
        'group'     => 'publiq-first-user',
        'mode'      => '0400',
        'content'   => "MFA configuration\n",
        'show_diff' => false
      ) }

      it { is_expected.to contain_file('/home/publiq-first-user/.google_authenticator').that_requires('User[publiq-first-user]') }
      it { is_expected.not_to contain_file('/home/publiq-missing-user/.google_authenticator') }
      it { is_expected.not_to contain_file('/home/publiq-inactive-user/.google_authenticator') }
      it { is_expected.not_to contain_file('/home/publiq-other-user/.google_authenticator') }

      context 'with custom bypass IPs' do
        let(:params) do
          super().merge({ 'bypass_ips' => ['192.0.2.1', '198.51.100.0/24'] })
        end

        it { is_expected.to contain_file('/etc/ssh/sshd_config.d/publiq-mfa.conf').with_content(
          %r{Match Group mfa_users Address \*,!192\.0\.2\.1,!198\.51\.100\.0/24}
        ) }
      end

      context 'without bypass IPs' do
        let(:params) do
          super().merge({ 'bypass_ips' => [] })
        end

        it { is_expected.to contain_file('/etc/ssh/sshd_config.d/publiq-mfa.conf').with_content(
          %r{Match Group mfa_users Address \*\n}
        ) }
      end

      context 'with MFA disabled' do
        let(:params) do
          super().merge({ 'enabled' => false })
        end

        it { is_expected.not_to contain_package('libpam-google-authenticator') }

        it { is_expected.to contain_file('/etc/pam.d/sshd').with_content(%r{@include common-auth}) }
        it { is_expected.to contain_file('/etc/pam.d/sshd').without_content(%r{pam_google_authenticator\.so}) }
        it { is_expected.to contain_file('/etc/pam.d/sshd').without_content(%r{pam_succeed_if\.so}) }

        it { is_expected.to contain_profiles__ssh__sshd_config('UsePAM').with_value('yes') }
        it { is_expected.to contain_profiles__ssh__sshd_config('ChallengeResponseAuthentication').with_value('no') }
        it { is_expected.to contain_profiles__ssh__sshd_config('AuthenticationMethods').with_ensure('absent') }
        it { is_expected.to contain_file('/etc/ssh/sshd_config.d/publiq-mfa.conf').with_ensure('absent') }
        it { is_expected.to contain_user('publiq-first-user').with_groups(['sudo']) }

        it { is_expected.not_to contain_file('/home/publiq-first-user/.google_authenticator') }
      end
    end
  end
end
