describe 'profiles::vault' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault').with(
          'version' => 'latest'
        ) }

        it { is_expected.to contain_apt__source('hashicorp') }
        it { is_expected.to contain_group('vault') }
        it { is_expected.to contain_user('vault') }

        it { is_expected.to contain_package('vault').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_apt__source('hashicorp').that_comes_before('Package[vault]') }
        it { is_expected.to contain_group('vault').that_comes_before('Package[vault]') }
        it { is_expected.to contain_user('vault').that_comes_before('Package[vault]') }
      end

      context 'with version => 1.2.3' do
        let(:params) { {
          'version' => '1.2.3'
        } }

        it { is_expected.to contain_package('vault').with(
          'ensure' => '1.2.3'
        ) }
      end
    end
  end
end
