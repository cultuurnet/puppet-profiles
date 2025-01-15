describe 'profiles::vault::secrets_engines' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_user('vault') }

        it { is_expected.to contain_exec('vault_kv_secrets_engine').with(
          'command'   => '/usr/bin/vault secrets enable -version=2 kv',
          'user'      => 'vault',
          'onlyif'    => '/usr/bin/test -z "$(/usr/bin/vault secrets list -format=json | /usr/bin/jq \'.[] | select(.type == "kv")\')"',
          'logoutput' => 'on_failure'
        ) }

        it { is_expected.to contain_exec('vault_kv_secrets_engine').that_requires('User[vault]') }
      end
    end
  end
end
