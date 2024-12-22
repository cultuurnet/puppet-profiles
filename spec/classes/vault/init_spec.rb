describe 'profiles::vault::init' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with auto_unseal => true' do
        let(:params) { {
          'auto_unseal' => true
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault::init').with(
          'auto_unseal' => true,
          'gpg_keys'    => []
        ) }

        it { is_expected.to contain_group('vault') }
        it { is_expected.to contain_user('vault') }
        it { is_expected.to contain_package('jq') }

        it { is_expected.to contain_class('profiles::vault::gpg_key').with(
          'full_name'     => 'Vault',
          'email_address' => 'vault@publiq.be'
        ) }

        it { is_expected.to contain_file('vault_process_init').with(
          'ensure'  => 'file',
          'path'    => '/usr/local/bin/vault-process-init',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0755',
          'source'  => 'puppet:///modules/profiles/vault/vault-process-init'
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

        it { is_expected.to contain_exec('vault_init').that_requires('User[vault]') }
        it { is_expected.to contain_exec('vault_init').that_requires('Class[profiles::vault::gpg_key]') }
        it { is_expected.to contain_exec('vault_init').that_requires('File[vault_process_init]') }
        it { is_expected.to contain_exec('vault_init').that_requires('Package[jq]') }
        it { is_expected.to contain_file('vault_initialized_external_fact').that_requires('Exec[vault_init]') }
      end

      context 'with auto_unseal => true and gpg_keys => xxxxx' do
        let(:params) { {
          'auto_unseal' => true,
          'gpg_keys'    => xxxxx
        } }
      end

      context 'with auto_unseal => false and gpg_keys => xxxx' do
        let(:params) { {
          'auto_unseal' => false,
          'gpg_keys'    => xxxxx
        } }
      end

      context 'with auto_unseal => false' do
        let(:params) { {
          'auto_unseal' => false
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /without auto_unseal, at least one GPG key has to be provided/) }
      end
    end
  end
end
