describe 'profiles::vault::configuration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

        context 'without parameters' do
          let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('vault') }
        it { is_expected.to contain_user('vault') }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'service_address' => '127.0.0.1',
          'certname'        => nil
        ) }

        it { is_expected.to contain_file('vault configuration').with(
          'ensure' => 'file',
          'path'   => '/etc/vault.d/vault.hcl',
          'owner'  => 'vault',
          'group'  => 'vault'
        ) }

        it { is_expected.to contain_file('vault configuration').with_content(/^\s*address\s+=\s+"127\.0\.0\.1:8200"$/) }
        it { is_expected.to contain_file('vault configuration').with_content(/^\s*tls_cert_file\s+=\s+"\/opt\/vault\/tls\/tls\.crt"$/) }
        it { is_expected.to contain_file('vault configuration').with_content(/^\s*tls_key_file\s+=\s+"\/opt\/vault\/tls\/tls\.key"$/) }

        it { is_expected.to contain_shellvar('VAULT_ADDR environment variable').with(
          'ensure'   => 'present',
          'variable' => 'VAULT_ADDR',
          'target'   => '/etc/environment',
          'value'    => 'https://127.0.0.1:8200',
        ) }

        it { is_expected.not_to contain_shellvar('VAULT_CACERT environment variable') }
        it { is_expected.not_to contain_class('profiles::vault::certificate') }

        it { is_expected.to contain_file('vault configuration').that_requires('Group[vault]') }
        it { is_expected.to contain_file('vault configuration').that_requires('User[vault]') }
      end

      context 'with service_address => 0.0.0.0 and certname => vault.example.com' do
        let(:params) { {
          'service_address' => '0.0.0.0',
          'certname'        => 'vault.example.com'
        } }

        it { is_expected.to contain_class('profiles::vault::certificate').with(
          'certname' => 'vault.example.com'
        ) }

        it { is_expected.to contain_shellvar('VAULT_CACERT environment variable').with(
          'ensure'   => 'present',
          'variable' => 'VAULT_CACERT',
          'target'   => '/etc/environment',
          'value'    => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
        ) }

        it { is_expected.to contain_file('vault configuration').with_content(/^\s*address\s+=\s+"0\.0\.0\.0:8200"$/) }
        it { is_expected.to contain_file('vault configuration').with_content(/^\s*tls_cert_file\s+=\s+"\/opt\/vault\/tls\/vault\.example\.com\.crt"$/) }
        it { is_expected.to contain_file('vault configuration').with_content(/^\s*tls_key_file\s+=\s+"\/opt\/vault\/tls\/vault\.example\.com\.key"$/) }
      end
    end
  end
end
