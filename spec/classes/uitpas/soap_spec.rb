describe 'profiles::uitpas::soap' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'in the production environment' do
        let(:environment) { 'production' }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with default parameters" do
            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::soap').with(
              'deployment'             => true,
              'magda_cert_generation'  => false,
              'fidus_cert_generation'  => false,
              'env_settings'           => {},
              'repository'             => 'uitpas-soap'
            ) }

            it { is_expected.to contain_class('profiles::java') }

            it { is_expected.to contain_class('profiles::uitpas::soap::deployment') }

            it { is_expected.to contain_file('/opt/uitpas-soap/env.properties').with(
              'ensure' => 'file',
              'owner'  => 'glassfish',
              'group'  => 'glassfish',
              'mode'   => '0644'
            ) }

          end

          context "with deployment => false" do
            let(:params) { {
              'deployment' => false
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::soap').with(
              'deployment' => false
            ) }

            it { is_expected.to contain_class('profiles::java') }

            it { is_expected.not_to contain_class('profiles::uitpas::soap::deployment') }
          end

          context "with deployment => true" do
            let(:params) { {
              'deployment' => true
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::soap').with(
              'deployment' => true
            ) }

            it { is_expected.to contain_class('profiles::uitpas::soap::deployment') }
          end
        end
      end

      context 'in the testing environment' do
        let(:environment) { 'testing' }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with deployment => false" do
            let(:params) { {
              'deployment' => false
            } }

            it { is_expected.not_to contain_class('profiles::uitpas::soap::deployment') }
          end

          context "with magda_cert_generation => true and deployment => true" do
            let(:params) { {
              'magda_cert_generation' => true,
              'deployment' => true
            } }


            let(:pre_condition) {
              'class { "profiles::uitpas::soap::magda":
              magda_sftp_path           => "/opt/uitpas/magda/sftp",
              magda_sftp_cert           => "magda-sftp.crt",
              magda_sftp_key            => "magda-sftp.key",
              magda_soap_path           => "/opt/uitpas/magda/soap",
              magda_soap_keystore       => "magda-soap.p12",
              magda_soap_truststore     => "magda-soap-truststore.jks",
              magda_soap_cert_password  => "cert_password",
              magda_soap_key_password   => "key_password",
              magda_soap_alias          => "magda-soap-alias"
              }'
            }

            it { is_expected.to contain_class('profiles::uitpas::soap::magda') }
            it { is_expected.to contain_class('profiles::uitpas::soap::deployment') }
          end

          context "with magda_cert_generation => true and deployment => false" do
            let(:params) { {
              'magda_cert_generation' => true,
              'deployment' => false
            } }
              let(:pre_condition) {
              'class { "profiles::uitpas::soap::magda":
              magda_sftp_path           => "/opt/uitpas/magda/sftp",
              magda_sftp_cert           => "magda-sftp.crt",
              magda_sftp_key            => "magda-sftp.key",
              magda_soap_path           => "/opt/uitpas/magda/soap",
              magda_soap_keystore       => "magda-soap.p12",
              magda_soap_truststore     => "magda-soap-truststore.jks",
              magda_soap_cert_password  => "cert_password",
              magda_soap_key_password   => "key_password",
              magda_soap_alias          => "magda-soap-alias"
              }'
            }


            it { is_expected.to contain_class('profiles::uitpas::soap::magda') }
            it { is_expected.not_to contain_class('profiles::uitpas::soap::deployment') }
          end

          context "with fidus_cert_generation => true and deployment => true" do
            let(:params) { {
              'fidus_cert_generation' => true,
              'deployment' => true
            } }

            let(:pre_condition) {
              'class { "profiles::uitpas::soap::fidus":
              fidus_sftp_path           => "/opt/uitpas/fidus/sftp",
              fidus_sftp_key            => "fidus-sftp.key",
              fidus_soap_path           => "/opt/uitpas/fidus/soap",
              fidus_soap_keystore       => "fidus-soap.p12",
              fidus_soap_cert_password  => "cert_password",
              fidus_soap_key_password   => "key_password",
              fidus_soap_alias          => "fidus-soap-alias"
              }'
            }

            it { is_expected.to contain_class('profiles::uitpas::soap::fidus') }
            it { is_expected.to contain_class('profiles::uitpas::soap::deployment') }
          end

          context "with fidus_cert_generation => true and deployment => false" do
            let(:params) { {
              'fidus_cert_generation' => true,
              'deployment' => false
            } }

                  let(:pre_condition) {
              'class { "profiles::uitpas::soap::fidus":
              fidus_sftp_path           => "/opt/uitpas/fidus/sftp",
              fidus_sftp_key            => "fidus-sftp.key",
              fidus_soap_path           => "/opt/uitpas/fidus/soap",
              fidus_soap_keystore       => "fidus-soap.p12",
              fidus_soap_cert_password  => "cert_password",
              fidus_soap_key_password   => "key_password",
              fidus_soap_alias          => "fidus-soap-alias"
              }'
            }
            it { is_expected.to contain_class('profiles::uitpas::soap::fidus') }
            it { is_expected.not_to contain_class('profiles::uitpas::soap::deployment') }
          end

          context "with env_settings" do
            let(:params) { {
              'env_settings' => {
                'database.host' => 'localhost',
                'database.port' => '5432',
                'app.debug' => 'true'
              }
            } }

            it { is_expected.to contain_file('/opt/uitpas-soap/env.properties').with_content(
              /database\.host=localhost/
            ) }

            it { is_expected.to contain_file('/opt/uitpas-soap/env.properties').with_content(
              /database\.port=5432/
            ) }

            it { is_expected.to contain_file('/opt/uitpas-soap/env.properties').with_content(
              /app\.debug=true/
            ) }
          end
        end
      end
    end
  end
end