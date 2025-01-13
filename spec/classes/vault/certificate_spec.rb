describe 'profiles::vault::certificate' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on host foo.example.com" do
        let(:node) { 'foo.example.com' }

        context "with certname => foo.example.com" do
          let(:params) { {
            'certname' => 'foo.example.com'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.not_to contain_puppet_certificate('foo.example.com') }

          it { is_expected.to contain_group('vault') }
          it { is_expected.to contain_user('vault') }

          it { is_expected.to contain_file('vault certificate').with(
            'ensure' => 'file',
            'path'   => '/opt/vault/tls/tls.crt',
            'owner'  => 'vault',
            'group'  => 'vault',
            'mode'   => '0600',
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/foo.example.com.pem'
          ) }

          it { is_expected.to contain_file('vault private key').with(
            'ensure' => 'file',
            'path'   => '/opt/vault/tls/tls.key',
            'owner'  => 'vault',
            'group'  => 'vault',
            'mode'   => '0600',
            'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/foo.example.com.pem'
          ) }

          it { is_expected.to contain_file('vault certificate').that_requires('Group[vault]') }
          it { is_expected.to contain_file('vault certificate').that_requires('User[vault]') }
          it { is_expected.to contain_file('vault private key').that_requires('Group[vault]') }
          it { is_expected.to contain_file('vault private key').that_requires('User[vault]') }
        end

        context "with certname => vault.example.com" do
          let(:params) { {
            'certname' => 'vault.example.com'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_puppet_certificate('vault.example.com').with(
            'ensure'               => 'present',
            'waitforcert'          => 60,
            'renewal_grace_period' => 5,
            'clean'                => true,
            'dns_alt_names'        => ['DNS:vault.example.com', 'IP:127.0.0.1']
          ) }

          it { is_expected.to contain_file('vault certificate').with(
            'path'   => '/opt/vault/tls/tls.crt',
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/vault.example.com.pem'
          ) }

          it { is_expected.to contain_file('vault private key').with(
            'path'   => '/opt/vault/tls/tls.key',
            'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/vault.example.com.pem'
          ) }

          it { is_expected.to contain_file('vault certificate').that_requires('Puppet_certificate[vault.example.com]') }
          it { is_expected.to contain_file('vault private key').that_requires('Puppet_certificate[vault.example.com]') }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'certname'/) }
      end
    end
  end
end
