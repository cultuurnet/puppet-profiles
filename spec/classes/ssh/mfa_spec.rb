describe 'profiles::ssh::mfa' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) do
        [
          "profiles::users::shell { 'Publiq First User': uid => 5000, active => true, admin => true }",
          "profiles::users::shell { 'Publiq Missing User': uid => 5001, active => true }",
          "profiles::users::shell { 'Publiq Inactive User': uid => 5002, active => false }",
          "profiles::users::shell { 'Publiq Other User': uid => 5003, active => true }",
          "profiles::users::shell { 'Publiq Disabled User': uid => 5004, active => true }"
        ]
      end
      let(:params) do
        {
          'enabled'              => true,
          'authorized_keys'      => {
            'Publiq First User'    => { 'tags' => ['publiq', 'bastion'], 'admin' => true },
            'Publiq Missing User'  => { 'tags' => 'bastion' },
            'Publiq Inactive User' => { 'tags' => 'bastion', 'active' => false },
            'Publiq Other User'    => { 'tags' => 'other' },
            'Publiq Disabled User' => { 'tags' => 'bastion', 'mfa' => false }
          },
          'authorized_keys_tags' => 'bastion',
          'mfa_directory'        => File.expand_path('../../support/mfa', __dir__)
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::ssh::mfa').with(
        'enabled'              => true,
        'enforced'             => false,
        'authorized_keys_tags' => 'bastion',
        'bypass_ips'           => ['194.78.13.220']
      ) }

      it { is_expected.to contain_package('libpam-google-authenticator').with(
        'ensure' => 'installed'
      ) }

      it { is_expected.to contain_group('mfa_users').with(
        'ensure' => 'present',
        'gid'    => '1008'
      ) }
      it { is_expected.to contain_profiles__users__shell('Publiq First User').with(
        'mfa'          => true,
        'mfa_enforced' => false,
        'mfa_config'   => File.expand_path('../../support/mfa/publiq-first-user.conf', __dir__)
      ) }
      it { is_expected.to contain_profiles__users__shell('Publiq Missing User').with(
        'mfa'          => false,
        'mfa_enforced' => false,
        'mfa_config'   => nil
      ) }
      it { is_expected.to contain_profiles__users__shell('Publiq Disabled User').with(
        'mfa'          => false,
        'mfa_enforced' => false,
        'mfa_config'   => nil
      ) }
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
      it { is_expected.to contain_package('libpam-google-authenticator').that_comes_before('File[/etc/pam.d/sshd]') }

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
      it { is_expected.to contain_file('/home/publiq-missing-user/.google_authenticator').with_ensure('absent') }
      it { is_expected.to contain_file('/home/publiq-inactive-user/.google_authenticator').with_ensure('absent') }
      it { is_expected.to contain_file('/home/publiq-other-user/.google_authenticator').with_ensure('absent') }
      it { is_expected.to contain_file('/home/publiq-disabled-user/.google_authenticator').with_ensure('absent') }

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

      context 'with MFA enforced' do
        let(:params) do
          super().merge({ 'enforced' => true })
        end

        it { is_expected.to contain_profiles__users__shell('Publiq Missing User').with(
          'mfa'          => true,
          'mfa_enforced' => true,
          'mfa_config'   => nil
        ) }

        it { is_expected.to contain_user('publiq-missing-user').with_groups(['mfa_users']) }
        it { is_expected.to contain_file('/home/publiq-missing-user/.google_authenticator').with_ensure('absent') }
        it { is_expected.to contain_profiles__users__shell('Publiq Disabled User').with(
          'mfa'          => false,
          'mfa_enforced' => true,
          'mfa_config'   => nil
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

        it { is_expected.to contain_file('/home/publiq-first-user/.google_authenticator').with_ensure('absent') }
      end
    end
  end
end
