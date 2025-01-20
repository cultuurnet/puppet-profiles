describe 'profiles::vault::policies' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('vault') }
        it { is_expected.to contain_user('vault') }

        it { is_expected.to contain_file('vault_policies').with(
          'ensure' => 'directory',
          'path'   => '/etc/vault.d/policies',
          'owner'  => 'vault',
          'group'  => 'vault'
        ) }

        it { is_expected.to contain_profiles__vault__policy('puppet_cert').with(
          'policy'             => 'path "puppet/*" { capabilities = ["read"] }',
          'policies_directory' => '/etc/vault.d/policies'
        ) }

        it { is_expected.to contain_file('vault_policies').that_requires('Group[vault]') }
        it { is_expected.to contain_file('vault_policies').that_requires('User[vault]') }
        it { is_expected.to contain_profiles__vault__policy('puppet_cert').that_requires('File[vault_policies]') }
      end
    end
  end
end
