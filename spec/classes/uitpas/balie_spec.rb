describe 'profiles::uitpas::balie' do
  context "with servername => balie.example.com" do
    let(:params) { {
      'servername' => 'balie.example.com'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "without extra parameters" do
          let(:params) {
            super().merge({})
          }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::balie').with(
              'servername'      => 'balie.example.com',
              'serveraliases'   => [],
              'deployment'      => true,
              'service_address' => '127.0.0.1',
              'service_port'    => 4000
            ) }

            it { is_expected.to contain_class('profiles::nodejs') }

            it { is_expected.to contain_class('profiles::uitpas::balie::deployment').with(
              'service_address' => '127.0.0.1',
              'service_port'    => 4000
            ) }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://balie.example.com').with(
              'destination' => 'http://127.0.0.1:4000/',
              'aliases'     => []
            ) }

            it { is_expected.to contain_class('profiles::uitpas::balie::deployment').that_requires('Class[profiles::nodejs]') }
          end

          context "without hieradata" do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
          end
        end
      end
    end
  end

  context "with servername => test.example.com, serveraliases => alias.example.com, service_address => 127.0.1.1 and service_port => 7000" do
    let(:params) { {
      'servername'      => 'test.example.com',
      'serveraliases'   => 'alias.example.com',
      'service_address' => '127.0.1.1',
      'service_port'    => 7000
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitpas::balie::deployment').with(
            'service_address' => '127.0.1.1',
            'service_port'    => 7000
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://test.example.com').with(
            'destination' => 'http://127.0.1.1:7000/',
            'aliases'     => 'alias.example.com'
          ) }

          context "with deployment => false" do
            let(:params) {
              super().merge({
                'deployment' => false
              })
            }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::nodejs') }
            it { is_expected.to_not contain_class('profiles::uitpas::balie::deployment') }
          end
        end
      end
    end
  end
end
