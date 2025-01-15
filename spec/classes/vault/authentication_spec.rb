describe 'profiles::vault::authentication' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('vault') }
        it { is_expected.to contain_user('vault') }

        it { is_expected.to contain_file('vault_trusted_certs').with(
          'ensure'   => 'directory',
          'path'     => '/etc/vault.d/trusted_certs',
          'owner'    => 'vault',
          'group'    => 'vault'
        ) }

        it { is_expected.to contain_exec('vault_cert_auth').with(
          'command'   => '/usr/bin/vault auth enable cert',
          'user'      => 'vault',
          'onlyif'    => '/usr/bin/test -z "$(/usr/bin/vault auth list -format=json | /usr/bin/jq \'.[] | select(.type == "cert")\')"',
          'logoutput' => 'on_failure'
        ) }

        it { is_expected.to contain_file('vault_trusted_certs').that_requires('Group[vault]') }
        it { is_expected.to contain_file('vault_trusted_certs').that_requires('User[vault]') }
        it { is_expected.to contain_exec('vault_cert_auth').that_requires('User[vault]') }
      end
    end
  end
end
