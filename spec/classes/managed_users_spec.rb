describe 'profiles::managed_users' do
  let(:hiera_config) { 'spec/support/hiera/common.yaml' }

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with managed users configured" do
        it { is_expected.to contain_profiles__managed_user('publiq-first').with(
          'keys' => { 'type' => 'ssh-rsa', 'key' => 'abcd' },
          'uid'  => 5000,
          'sudo' => true
        ) }

        it { is_expected.to contain_profiles__managed_user('publiq-second').with(
          'keys' => { 'type' => 'ssh-ed25519', 'key' => 'defg' },
          'uid'  => 5001,
          'sudo' => false
        ) }

        it { is_expected.not_to contain_profiles__managed_user('acme-first') }
      end
    end
  end
end
