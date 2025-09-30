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
              'fidus_cert_generation'  => false
            ) }

            it { is_expected.to contain_class('profiles::java') }

            it { is_expected.to contain_class('profiles::uitpas::soap::deployment') }

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

            it { is_expected.to contain_class('profiles::uitpas::soap::magda') }
            it { is_expected.to contain_class('profiles::uitpas::soap::deployment') }
          end

          context "with magda_cert_generation => true and deployment => false" do
            let(:params) { {
              'magda_cert_generation' => true,
              'deployment' => false
            } }

            it { is_expected.to contain_class('profiles::uitpas::soap::magda') }
            it { is_expected.not_to contain_class('profiles::uitpas::soap::deployment') }
          end

          context "with fidus_cert_generation => true and deployment => true" do
            let(:params) { {
              'fidus_cert_generation' => true,
              'deployment' => true
            } }

            it { is_expected.to contain_class('profiles::uitpas::soap::fidus') }
            it { is_expected.to contain_class('profiles::uitpas::soap::deployment') }
          end

          context "with fidus_cert_generation => true and deployment => false" do
            let(:params) { {
              'fidus_cert_generation' => true,
              'deployment' => false
            } }

            it { is_expected.to contain_class('profiles::uitpas::soap::fidus') }
            it { is_expected.not_to contain_class('profiles::uitpas::soap::deployment') }
          end
        end
      end
    end
  end
end