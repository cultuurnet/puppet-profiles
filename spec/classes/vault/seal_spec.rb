describe 'profiles::vault::seal' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault::seal').with(
          'gpg_keys' => []
        ) }

        it { is_expected.to contain_group('vault') }
        it { is_expected.to contain_user('vault') }

        it { is_expected.to contain_class('profiles::vault::gpg_key').with(
          'full_name'     => 'Vault',
          'email_address' => 'vault@publiq.be'
        ) }

        context 'without fact vault_initialized' do
          it { is_expected.to contain_exec('vault_init').with(
            'command'   => '/usr/bin/vault operator init -key-shares=1 -key-threshold=1 -pgp-keys="/etc/vault.d/gpg_keys/vault.asc" -format=json -tls-skip-verify',
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

          it { is_expected.to contain_exec('vault_init').that_requires('User[vault]') }
          it { is_expected.to contain_exec('vault_init').that_requires('Class[profiles::vault::gpg_key]') }
          it { is_expected.to contain_file('vault_initialized_external_fact').that_requires('Exec[vault_init]') }
        end

        context 'with fact vault_initialized' do
          let(:facts) { facts.merge({ 'vault_initialized' => true }) }

          it { is_expected.not_to contain_exec('vault init') }
          it { is_expected.not_to contain_file('vault_initialized_external_fact') }
        end
      end

      context 'with' do
        let(:params) { {
        } }
      end
    end
  end
end
