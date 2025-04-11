describe 'profiles::uitpas::groepspas' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with servername => groepspas.example.com" do
        let(:params) { {
          'servername' => 'groepspas.example.com'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitpas::groepspas').with(
            'servername'    => 'groepspas.example.com',
            'serveraliases' => [],
            'deployment'    => true
          ) }

          it { is_expected.to contain_class('profiles::uitpas::groepspas::deployment') }

          it { is_expected.to contain_profiles__apache__vhost__basic('http://groepspas.example.com').with(
            'serveraliases' => [],
            'documentroot'  => '/var/www/uitpas-groepspas'
          ) }
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context "with servername => test.example.com, serveraliases => alias.example.com" do
        let(:params) { {
          'servername'    => 'test.example.com',
          'serveraliases' => 'alias.example.com'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__apache__vhost__basic('http://test.example.com').with(
            'serveraliases' => 'alias.example.com',
            'documentroot'  => '/var/www/uitpas-groepspas',
          ) }
        end

        context "with deployment => false" do
          let(:params) {
            super().merge({ 'deployment' => false })
          }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to_not contain_class('profiles::uitpas::groepspas::deployment') }
        end
      end
    end
  end
end
