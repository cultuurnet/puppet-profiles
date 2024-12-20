describe 'profiles::vault::seal' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault::seal').with(
          'auto_unseal' => false
        ) }

        it { is_expected.to contain_group('vault') }
        it { is_expected.to contain_user('vault') }

        it { is_expected.to contain_file('vault_unseal').with(
          'ensure' => 'absent',
          'path'   => '/usr/local/bin/vault-unseal'
        ) }

        it { is_expected.not_to contain_exec('vault_unseal') }

        it { is_expected.to contain_systemd__dropin_file('vault_override.conf').with(
          'unit'           => 'vault.service',
          'ensure'         => 'absent',
          'filename'       => 'override.conf',
          'notify_service' => false
        ) }
      end

      context 'with auto_unseal => true' do
        let(:params) { {
          'auto_unseal' => true
        } }

        it { is_expected.to contain_file('vault_unseal').with(
          'ensure' => 'file',
          'path'   => '/usr/local/bin/vault-unseal',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('vault_unseal').with_content() }

        it { is_expected.to contain_exec('vault_unseal').with(
          'command'   => '/usr/local/bin/vault-unseal /home/vault/encrypted_unseal_key',
          'user'      => 'vault',
          'unless'    => '/usr/bin/vault status -tls-skip-verify',
          'logoutput' => 'on_failure'
        ) }

        it { is_expected.to contain_systemd__dropin_file('vault_override.conf').with(
          'unit'           => 'vault.service',
          'ensure'         => 'present',
          'filename'       => 'override.conf',
          'notify_service' => false,
          'content'        => '[Service]\nExecStartPost=/usr/local/bin/vault-unseal /home/vault/encrypted_unseal_key'
        ) }

        it { is_expected.to contain_exec('vault_unseal').that_requires('File[vault_unseal]') }
        it { is_expected.to contain_systemd__dropin_file('vault_override.conf').that_requires('File[vault_unseal]') }
      end
    end
  end
end
