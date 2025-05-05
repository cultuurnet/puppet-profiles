describe 'profiles::uitpas::balie_frontend' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitpas::balie_frontend').with(
            'deployment' => true
          ) }

          it { is_expected.to contain_class('profiles::apache') }

          it { is_expected.to contain_apache__mod('access_compat') }

          it { is_expected.to contain_class('profiles::uitpas::balie_frontend::deployment') }
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context 'with deployment => false' do
        let(:params) { {
          'deployment' => false
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::apache') }

        it { is_expected.to contain_apache__mod('access_compat') }

        it { is_expected.to_not contain_class('profiles::uitpas::balie_frontend::deployment') }
      end
    end
  end
end
