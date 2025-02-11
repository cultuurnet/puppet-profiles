describe 'profiles::vault::authentication' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault::authentication').with(
          'lease_ttl_seconds' => nil
        ) }

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
          'unless'    => '/usr/bin/vault auth list -format=json | /usr/bin/jq -e \'."cert/"\'',
          'logoutput' => 'on_failure'
        ) }

        it { is_expected.not_to contain_exec('vault_cert_default_lease_ttl') }
        it { is_expected.not_to contain_exec('vault_cert_max_lease_ttl') }

        it { is_expected.to contain_file('vault_trusted_certs').that_requires('Group[vault]') }
        it { is_expected.to contain_file('vault_trusted_certs').that_requires('User[vault]') }
        it { is_expected.to contain_exec('vault_cert_auth').that_requires('User[vault]') }
      end

      context 'with lease_ttl_seconds => 60' do
        let(:params) { {
          'lease_ttl_seconds' => 60
        } }

        it { is_expected.to contain_exec('vault_cert_default_lease_ttl').with(
          'command'   => '/usr/bin/vault auth tune -default-lease-ttl=60 cert',
          'user'      => 'vault',
          'unless'    => '/usr/bin/vault read -format=json sys/auth/cert/tune | /usr/bin/jq -e \'.data | select(.default_lease_ttl==60)\'',
          'logoutput' => 'on_failure'
        ) }

        it { is_expected.to contain_exec('vault_cert_max_lease_ttl').with(
          'command'   => '/usr/bin/vault auth tune -max-lease-ttl=60 cert',
          'user'      => 'vault',
          'unless'    => '/usr/bin/vault read -format=json sys/auth/cert/tune | /usr/bin/jq -e \'.data | select(.max_lease_ttl==60)\'',
          'logoutput' => 'on_failure'
        ) }

        it { is_expected.to contain_exec('vault_cert_default_lease_ttl').that_requires('User[vault]') }
        it { is_expected.to contain_exec('vault_cert_default_lease_ttl').that_requires('Exec[vault_cert_auth]') }
        it { is_expected.to contain_exec('vault_cert_max_lease_ttl').that_requires('User[vault]') }
        it { is_expected.to contain_exec('vault_cert_max_lease_ttl').that_requires('Exec[vault_cert_auth]') }
      end
    end
  end
end
