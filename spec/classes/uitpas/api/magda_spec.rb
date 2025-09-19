describe 'profiles::uitpas::api::magda' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with required parameters" do
        let(:params) { {
          'magda_sftp_path'           => '/opt/uitpas/magda/sftp',
          'magda_sftp_cert'           => 'magda-sftp.crt',
          'magda_sftp_key'            => 'magda-sftp.key',
          'magda_soap_path'           => '/opt/uitpas/magda/soap',
          'magda_soap_keystore'       => 'magda-soap.p12',
          'magda_soap_truststore'     => 'magda-soap-truststore.jks',
          'magda_soap_cert_password'  => 'cert_password',
          'magda_soap_key_password'   => 'key_password',
          'magda_soap_alias'          => 'magda-soap-alias'
        } }

        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitpas::api::magda').with(
          'magda_sftp_path'           => '/opt/uitpas/magda/sftp',
          'magda_sftp_cert'           => 'magda-sftp.crt',
          'magda_sftp_key'            => 'magda-sftp.key',
          'magda_soap_path'           => '/opt/uitpas/magda/soap',
          'magda_soap_keystore'       => 'magda-soap.p12',
          'magda_soap_truststore'     => 'magda-soap-truststore.jks',
          'magda_soap_cert_password'  => 'cert_password',
          'magda_soap_key_password'   => 'key_password',
          'magda_soap_alias'          => 'magda-soap-alias'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/magda/soap').with(
          'ensure' => 'directory',
          'owner'  => 'glassfish',
          'group'  => 'glassfish',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/magda/sftp').with(
          'ensure' => 'directory',
          'owner'  => 'glassfish',
          'group'  => 'glassfish',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/magda/sftp/magda-sftp.crt').with(
          'ensure'  => 'file',
          'owner'   => 'glassfish',
          'group'   => 'glassfish',
          'mode'    => '0644'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/magda/sftp/magda-sftp.crt').that_requires('File[/opt/uitpas/magda/sftp]') }

        it { is_expected.to contain_file('/opt/uitpas/magda/sftp/magda-sftp.key').with(
          'ensure'  => 'file',
          'owner'   => 'glassfish',
          'group'   => 'glassfish',
          'mode'    => '0600'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/magda/sftp/magda-sftp.key').that_requires('File[/opt/uitpas/magda/sftp]') }

        it { is_expected.to contain_file('/opt/uitpas/magda/soap/magda-soap-cert.crt').with(
          'ensure'     => 'file',
          'owner'      => 'glassfish',
          'group'      => 'glassfish',
          'mode'       => '0644'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/magda/soap/magda-soap-cert.crt').that_requires('File[/opt/uitpas/magda/soap]') }
        it { is_expected.to contain_file('/opt/uitpas/magda/soap/magda-soap-cert.crt').that_notifies('Openssl::Export::Pkcs12[magda-soap-alias]') }

        it { is_expected.to contain_file('/opt/uitpas/magda/soap/magda-soap-key.pem').with(
          'ensure'  => 'file',
          'owner'   => 'glassfish',
          'group'   => 'glassfish',
          'mode'    => '0600'
        ) }

        it { is_expected.to contain_file('/opt/uitpas/magda/soap/magda-soap-key.pem').that_requires('File[/opt/uitpas/magda/soap]') }
        it { is_expected.to contain_file('/opt/uitpas/magda/soap/magda-soap-key.pem').that_notifies('Openssl::Export::Pkcs12[magda-soap-alias]') }

        it { is_expected.to contain_openssl__export__pkcs12('magda-soap-alias').with(
          'ensure'   => 'present',
          'basedir'  => '/opt/uitpas/magda/soap',
          'pkey'     => '/tmp/magda-soap-key.pem',
          'cert'     => '/tmp/magda-soap-cert.crt',
          'out_pass' => 'cert_password'
        ) }

        it { is_expected.to contain_openssl__export__pkcs12('magda-soap-alias').that_requires(['File[/opt/uitpas/magda/soap/magda-soap-cert.crt]', 'File[/opt/uitpas/magda/soap/magda-soap-key.pem]']) }
        it { is_expected.to contain_openssl__export__pkcs12('magda-soap-alias') }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::PreformattedError, /expects a value for parameter/) }
      end
    end
  end
end