describe 'profiles::vault::secrets_engines' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_user('vault') }

        it { is_expected.to contain_exec('vault_puppet_kv_secrets_engine').with(
          'command'   => '/usr/bin/vault secrets enable -version=2 -path=puppet kv',
          'user'      => 'vault',
          'unless'    => '/usr/bin/vault secrets list -format=json | /usr/bin/jq -e \'."puppet/"\'',
          'logoutput' => 'on_failure'
        ) }

        it { is_expected.to contain_exec('vault_puppet_kv_secrets_engine').that_requires('User[vault]') }
      end
    end
  end
end
