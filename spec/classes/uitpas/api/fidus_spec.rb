describe 'profiles::uitpas::api::fidus' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with required parameters" do
        let(:params) { {
          'fidus_sftp_path'          => '/opt/uitpas/fidus/sftp',
          'fidus_sftp_key'            => 'fidus-sftp.key',
          'fidus_soap_path'           => '/opt/uitpas/fidus/soap',
          'fidus_soap_keystore'       => 'fidus-soap.p12',
          'fidus_soap_cert_password'  => 'cert_password',
          'fidus_soap_key_password'   => 'key_password',
          'fidus_soap_alias'          => 'fidus-soap-alias'
        } }

        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitpas::api::fidus').with(
          'fidus_sftp_path'           => '/opt/uitpas/fidus/sftp',
          'fidus_sftp_key'            => 'fidus-sftp.key',
          'fidus_soap_path'           => '/opt/uitpas/fidus/soap',
          'fidus_soap_keystore'       => 'fidus-soap.p12',
          'fidus_soap_cert_password'  => 'cert_password',
          'fidus_soap_key_password'   => 'key_password',
          'fidus_soap_alias'          => 'fidus-soap-alias'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/fidus/soap').with(
          'ensure' => 'directory',
          'owner'  => 'glassfish',
          'group'  => 'glassfish',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/fidus/sftp').with(
          'ensure' => 'directory',
          'owner'  => 'glassfish',
          'group'  => 'glassfish',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/fidus/sftp/fidus-sftp.key').with(
          'ensure'  => 'file',
          'owner'   => 'glassfish',
          'group'   => 'glassfish',
          'mode'    => '0600'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/fidus/sftp/fidus-sftp.key').that_requires('File[/opt/uitpas/fidus/sftp]') }

        it { is_expected.to contain_file('/opt/uitpas/fidus/soap/fidus-soap-cert.crt').with(
          'ensure'     => 'file',
          'owner'      => 'glassfish',
          'group'      => 'glassfish',
          'mode'       => '0644'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/fidus/soap/fidus-soap-cert.crt').that_requires('File[/opt/uitpas/fidus/soap]') }
        it { is_expected.to contain_file('/opt/uitpas/fidus/soap/fidus-soap-cert.crt').that_notifies('Openssl::Export::Pkcs12[fidus-soap-alias]') }

        it { is_expected.to contain_file('/opt/uitpas/fidus/soap/fidus-soap-key.pem').with(
          'ensure'  => 'file',
          'owner'   => 'glassfish',
          'group'   => 'glassfish',
          'mode'    => '0600'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/fidus/soap/fidus-soap-key.pem').that_requires('File[/opt/uitpas/fidus/soap]') }
        it { is_expected.to contain_file('/opt/uitpas/fidus/soap/fidus-soap-key.pem').that_notifies('Openssl::Export::Pkcs12[fidus-soap-alias]') }

        it { is_expected.to contain_openssl__export__pkcs12('fidus-soap-alias').with(
          'ensure'   => 'present',
          'basedir'  => '/opt/uitpas/fidus/soap',
          'pkey'     => '/opt/uitpas/fidus/soap/fidus-soap-key.pem',
          'cert'     => '/opt/uitpas/fidus/soap/fidus-soap-cert.crt',
          'out_pass' => 'cert_password'
        ).that_notifies('Exec[chown_fidus-soap-alias]') }

        it { is_expected.to contain_openssl__export__pkcs12('fidus-soap-alias').that_requires(['File[/opt/uitpas/fidus/soap/fidus-soap-cert.crt]', 'File[/opt/uitpas/fidus/soap/fidus-soap-key.pem]']) }
        it { is_expected.to contain_openssl__export__pkcs12('fidus-soap-alias') }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::PreformattedError, /expects a value for parameter/) }
      end
    end
  end
end