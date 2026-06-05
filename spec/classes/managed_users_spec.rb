describe 'profiles::managed_users' do
  let(:hiera_config) { 'spec/support/hiera/common.yaml' }

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "without virtual resources realized" do
        it { is_expected.not_to contain_profiles__managed_user('publiq-first') }
        it { is_expected.not_to contain_profiles__managed_user('publiq-second') }
        it { is_expected.not_to contain_profiles__managed_user('acme-first') }
      end

      context "with all managed users realized" do
        let(:pre_condition) { 'Profiles::Managed_user <| |>' }

        it { is_expected.to contain_profiles__managed_user('publiq-first').with(
          'key_name' => 'publiq first key',
          'keys'     => { 'type' => 'ssh-rsa', 'key' => 'abcd' },
          'uid'      => 5000,
          'sudo'     => true,
          'tags'     => 'publiq',
          'tag'      => 'publiq'
        ) }

        it { is_expected.to contain_profiles__managed_user('publiq-second').with(
          'key_name' => 'publiq second key',
          'keys'     => { 'type' => 'ssh-ed25519', 'key' => 'defg' },
          'uid'      => 5001,
          'sudo'     => false,
          'tags'     => ['publiq', 'example'],
          'tag'      => ['publiq', 'example']
        ) }

        it { is_expected.not_to contain_profiles__managed_user('acme-first') }
      end
    end
  end
end
