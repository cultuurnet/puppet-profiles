describe 'profiles::vault::configuration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on host foo.example.com" do
        let(:node) { 'foo.example.com' }

        context 'without parameters' do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::vault::configuration').with(
            'service_address' => '127.0.0.1',
            'certname'        => 'foo.example.com'
          ) }

          it { is_expected.to contain_shellvar('VAULT_ADDR environment variable').with(
            'ensure'   => 'present',
            'variable' => 'VAULT_ADDR',
            'target'   => '/etc/environment',
            'value'    => 'https://127.0.0.1:8200',
          ) }

          it { is_expected.to contain_shellvar('VAULT_CACERT environment variable').with(
            'ensure'   => 'present',
            'variable' => 'VAULT_CACERT',
            'target'   => '/etc/environment',
            'value'    => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
          ) }

          it { is_expected.to contain_class('profiles::vault::certificate').with(
            'certname' => 'foo.example.com'
          ) }
        end

        context 'with service_address => 0.0.0.0 and certname => vault.example.com' do
          let(:params) { {
            'service_address' => '0.0.0.0',
            'certname'        => 'vault.example.com'
          } }

          it { is_expected.to contain_class('profiles::vault::certificate').with(
            'certname' => 'vault.example.com'
          ) }
        end
      end
    end
  end
end
