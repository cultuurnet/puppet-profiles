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
          'auto_unseal'   => true,
          'key_threshold' => 1,
          'gpg_keys'      => {}
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

      context 'with auto_unseal => true and gpg_keys => { ghi789 => { tag => baz, key => -----BEGIN PGP PUBLIC KEY BLOCK-----\nzyx987\n-----END PGP PUBLIC KEY BLOCK----- } }' do
        let(:params) { {
          'auto_unseal' => true,
          'gpg_keys'    => { 'ghi789' => { 'tag' => 'baz', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nzyx987\n-----END PGP PUBLIC KEY BLOCK-----" } }
        } }

        it { is_expected.to contain_exec('vault_init').with(
          'command'   => '/usr/bin/vault operator init -key-shares=2 -key-threshold=1 -pgp-keys="/etc/vault.d/gpg_keys/vault.asc,/etc/vault.d/gpg_keys/ghi789.asc" -tls-skip-verify -format=json | /usr/local/bin/vault-process-init',
          'user'      => 'vault',
          'logoutput' => 'on_failure'
        ) }
      end

      context 'with auto_unseal => false, key_threshold => 2 and gpg_keys => { abc123 => { tag => foo, key => -----BEGIN PGP PUBLIC KEY BLOCK-----\nxyz789\n-----END PGP PUBLIC KEY BLOCK----- }, def456 => { tag => bar, key => -----BEGIN PGP PUBLIC KEY BLOCK-----\n987zyx\n-----END PGP PUBLIC KEY BLOCK----- } }' do
        let(:params) { {
          'auto_unseal'   => false,
          'key_threshold' => 2,
          'gpg_keys'      => {
                               'abc123' => { 'tag' => 'foo', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\nxyz789\n-----END PGP PUBLIC KEY BLOCK-----" },
                               'def456' => { 'tag' => 'bar', 'key' => "-----BEGIN PGP PUBLIC KEY BLOCK-----\n987zyx\n-----END PGP PUBLIC KEY BLOCK-----" }
                             }
        } }

        it { is_expected.to contain_exec('vault_init').with(
          'command'   => '/usr/bin/vault operator init -key-shares=2 -key-threshold=2 -pgp-keys="/etc/vault.d/gpg_keys/abc123.asc,/etc/vault.d/gpg_keys/def456.asc" -tls-skip-verify -format=json | /usr/local/bin/vault-process-init',
          'user'      => 'vault',
          'logoutput' => 'on_failure'
        ) }
      end

      context 'with auto_unseal => true and key_threshold => 3' do
        let(:params) { {
          'auto_unseal'   => true,
          'key_threshold' => 3
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /with auto_unseal, key threshold cannot be higher than 1/) }
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
