describe 'profiles::bastion::mfa' do
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
          'users'         => {
            'Publiq First User'    => { 'tags' => ['publiq', 'bastion'] },
            'Publiq Missing User'  => { 'tags' => 'bastion' },
            'Publiq Inactive User' => { 'tags' => 'bastion', 'active' => false },
            'Publiq Other User'    => { 'tags' => 'other' }
          },
          'user_tags'     => 'bastion',
          'mfa_directory' => File.expand_path('../../support/mfa', __dir__)
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::bastion::mfa').with(
        'user_tags' => 'bastion'
      ) }

      it { is_expected.to contain_file('/home/publiq-first-user/.google_authenticator').with(
        'ensure'    => 'file',
        'owner'     => 'publiq-first-user',
        'group'     => 'publiq-first-user',
        'mode'      => '0600',
        'content'   => "MFA configuration\n",
        'show_diff' => false
      ) }

      it { is_expected.to contain_file('/home/publiq-first-user/.google_authenticator').that_requires('User[publiq-first-user]') }
      it { is_expected.not_to contain_file('/home/publiq-missing-user/.google_authenticator') }
      it { is_expected.not_to contain_file('/home/publiq-inactive-user/.google_authenticator') }
      it { is_expected.not_to contain_file('/home/publiq-other-user/.google_authenticator') }
    end
  end
end
