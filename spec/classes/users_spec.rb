describe 'profiles::users' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('Profiles::Users').with(
          'shell'      => {},
          'shell_tags' => []
        ) }

        it { is_expected.to contain_class('Profiles::Users::Software') }

        it { is_expected.to have_profiles__users__shell_resource_count(0) }
      end

      context 'with shell => { user1 => { active => true, admin => true, tags => [foo, bar] }, user2 => { active => false, admin => false, tags => baz }, user3 => { tags => bar } } and shell_tags => bar' do
        let(:params) { {
          'shell'     => {
                            'user1' => { 'uid' => 5000, 'active' => true, 'admin' => true, 'mfa' => false, 'mfa_config' => '/tmp/user1.conf', 'tags' => ['foo', 'bar'] },
                            'user2' => { 'uid' => 5001, 'active' => false, 'admin' => false, 'tags' => 'baz' },
                            'user3' => { 'uid' => 5002, 'tags' => 'bar' }
                          },
          'shell_tags' => 'bar'
        } }

        it { is_expected.to contain_profiles__users__shell('user1').with(
          'uid'    => 5000,
          'active' => true,
          'admin'  => true,
          'mfa'    => false,
          'mfa_config' => '/tmp/user1.conf',
          'tag'    => ['foo', 'bar']
        ) }

        it { is_expected.to contain_profiles__users__shell('user2').with(
          'uid'    => 5001,
          'active' => false,
          'admin'  => false,
          'mfa'    => true,
          'mfa_config' => nil,
          'tag'    => 'baz'
        ) }

        it { is_expected.to contain_user('user2').with_ensure('absent') }

        it { is_expected.to contain_profiles__users__shell('user3').with(
          'uid'    => 5002,
          'active' => false,
          'admin'  => false,
          'mfa'    => true,
          'mfa_config' => nil,
          'tag'    => 'bar'
        ) }
      end
    end
  end
end
