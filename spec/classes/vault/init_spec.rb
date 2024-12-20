describe 'profiles::vault::init' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault::init').with(
          'gpg_keys' => []
        ) }

        it { is_expected.to contain_group('vault') }
        it { is_expected.to contain_user('vault') }

        it { is_expected.to contain_class('profiles::vault::gpg_key').with(
          'full_name'     => 'Vault',
          'email_address' => 'vault@publiq.be'
        ) }

        it { is_expected.to contain_exec('vault_init').with(
          'command'   => '/usr/bin/vault operator init -key-shares=1 -key-threshold=1 -pgp-keys="/etc/vault.d/gpg_keys/vault.asc" -tls-skip-verify -format=json | /usr/local/bin/vault-process-init',
          'user'      => 'vault',
          'logoutput' => 'on_failure'
        ) }

        it { is_expected.to contain_file('vault_initialized_external_fact').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppetlabs/facter/facts.d/vault_initialized.txt',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => 'vault_initialized=true'
        ) }
      end

      context 'with gpg_keys => xxxxx' do
        let(:params) { {
          'gpg_keys' => xxxxx
        } }
      end
    end
  end
end
