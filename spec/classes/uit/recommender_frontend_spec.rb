describe 'profiles::uit::recommender_frontend' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with servername => recommender.example.com" do
        let(:params) { {
          'servername' => 'recommender.example.com'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uit::recommender_frontend').with(
            'servername'    => 'recommender.example.com',
            'serveraliases' => [],
            'deployment'    => true,
            'service_port'  => 6000
          ) }

          it { is_expected.to contain_class('profiles::nodejs') }

          it { is_expected.to contain_class('profiles::uit::recommender_frontend::deployment').with(
            'service_port' => 6000
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://recommender.example.com').with(
            'destination' => 'http://127.0.0.1:6000/',
            'aliases'     => []
          ) }

          it { is_expected.to contain_class('profiles::uit::recommender_frontend::deployment').that_requires('Class[profiles::nodejs]') }

          context "with deployment => false" do
            let(:params) {
              super().merge( {'deployment' => false } )
            }

            it { is_expected.to_not contain_class('profiles::uit::recommender_frontend::deployment') }
          end
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context "with servername => myrecommender.example.com, serveraliases => [foo.example.com, bar.example.com] and service_port => 9876" do
        let(:params) { {
          'servername'    => 'myrecommender.example.com',
          'serveraliases' => ['foo.example.com', 'bar.example.com'],
          'service_port'  => 9876
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_class('profiles::uit::recommender_frontend::deployment').with(
            'service_port' => 9876
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://myrecommender.example.com').with(
            'destination' => 'http://127.0.0.1:9876/',
            'aliases'     => ['foo.example.com', 'bar.example.com']
          ) }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
