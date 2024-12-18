describe 'profiles::vault::gpg_key' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with full_name => Vault and email_address => vault@example.com' do
        let(:params) { {
          'full_name'     => 'Vault',
          'email_address' => 'vault@example.com',
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault::gpg_key').with(
          'full_name'     => 'Vault',
          'email_address' => 'vault@example.com',
          'key_length'    => 4096
        ) }

        it { is_expected.to contain_group('vault') }
        it { is_expected.to contain_user('vault') }

        it { is_expected.to contain_file('vault_gpg_key_gen_script').with(
          'ensure' => 'file',
          'path'   => '/etc/vault.d/gpg_key_gen_script',
          'owner'  => 'vault',
          'group'  => 'vault'
        ) }

        it { is_expected.to contain_file('vault_gpg_key_gen_script').with_content(/^Key-Type: 1$/) }
        it { is_expected.to contain_file('vault_gpg_key_gen_script').with_content(/^Expire-Date: 0$/) }
        it { is_expected.to contain_file('vault_gpg_key_gen_script').with_content(/^Key-Length: 4096$/) }
        it { is_expected.to contain_file('vault_gpg_key_gen_script').with_content(/^Subkey-Length: 4096$/) }
        it { is_expected.to contain_file('vault_gpg_key_gen_script').with_content(/^Name-Real: Vault$/) }
        it { is_expected.to contain_file('vault_gpg_key_gen_script').with_content(/^Name-Email: vault@example.com$/) }
        it { is_expected.to contain_file('vault_gpg_key_gen_script').with_content(/^%no-protection$/) }

        it { is_expected.to contain_exec('vault_gpg_key').with(
          'command'   => '/usr/bin/gpg --full-gen-key --batch /etc/vault.d/gpg_key_gen_script',
          'user'      => 'vault',
          'unless'    => '/usr/bin/gpg --fingerprint vault@example.com',
          'logoutput' => 'on_failure'
        ) }

        it { is_expected.to contain_file('vault_gpg_key_gen_script').that_requires('Group[vault]') }
        it { is_expected.to contain_file('vault_gpg_key_gen_script').that_requires('User[vault]') }
        it { is_expected.to contain_exec('vault_gpg_key').that_requires('File[vault_gpg_key_gen_script]') }
      end

      context 'with full_name => foo, email_address => foo@bar.com and key_length => 2048' do
        let(:params) { {
          'full_name'     => 'foo',
          'email_address' => 'foo@bar.com',
          'key_length'    => 2048
        } }

        it { is_expected.to contain_file('vault_gpg_key_gen_script').with_content(/^Key-Length: 2048$/) }
        it { is_expected.to contain_file('vault_gpg_key_gen_script').with_content(/^Subkey-Length: 2048$/) }
        it { is_expected.to contain_file('vault_gpg_key_gen_script').with_content(/^Name-Real: foo$/) }
        it { is_expected.to contain_file('vault_gpg_key_gen_script').with_content(/^Name-Email: foo@bar.com$/) }

        it { is_expected.to contain_exec('vault_gpg_key').with(
          'command'   => '/usr/bin/gpg --full-gen-key --batch /etc/vault.d/gpg_key_gen_script',
          'user'      => 'vault',
          'unless'    => '/usr/bin/gpg --fingerprint foo@bar.com',
          'logoutput' => 'on_failure'
        ) }

      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'full_name'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'email_address'/) }
      end
    end
  end
end
