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

      context 'with shell => { user1 => { tags => [foo, bar] }, user2 => { tags => baz }, user3 => { tags => bar } } and shell_tags => bar' do
        let(:params) { {
          'shell'     => {
                            'user1' => { 'uid' => 5000, 'tags' => ['foo', 'bar'] },
                            'user2' => { 'uid' => 5001, 'tags' => 'baz' },
                            'user3' => { 'uid' => 5002, 'tags' => 'bar' }
                          },
          'shell_tags' => 'bar'
        } }

        it { is_expected.to contain_profiles__users__shell('user1').with(
          'uid' => 5000,
          'tag' => ['foo', 'bar']
        ) }

        it { is_expected.to contain_profiles__users__shell('user3').with(
          'uid' => 5002,
          'tag' => 'bar'
        ) }

        it { is_expected.not_to contain_profiles__users__shell('user2') }
      end
    end
  end
end
