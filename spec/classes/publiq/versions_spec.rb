describe 'profiles::publiq::versions' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with servername => 'versions.local'" do
        let(:params) { {
          'servername' => 'versions.local'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::publiq::versions').with(
          'servername'      => 'versions.local',
          'serveraliases'   => [],
          'deployment'      => true,
          'service_address' => '127.0.0.1',
          'service_port'    => '3000'
        ) }

        it { is_expected.to contain_class('profiles::ruby') }
        it { is_expected.to contain_class('profiles::apache') }

        it { is_expected.to contain_class('profiles::publiq::versions::deployment') }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://versions.local').with(
          'destination' => 'http://127.0.0.1:3000/',
          'aliases'     => []
        ) }

        it { is_expected.to contain_class('profiles::publiq::versions::deployment').that_requires('Class[profiles::ruby]') }

        context "with service_address => 0.0.0.0 and service_port => 5000" do
          let(:params)  { super().merge( {
              'service_address' => '0.0.0.0',
              'service_port'    => 5000
          } ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://versions.local').with(
            'destination' => 'http://0.0.0.0:5000/',
            'aliases'     => []
          ) }
        end
      end

      context "with servername => versions.publiq.dev, serveraliases => foo.example.com and deployment => false" do
        let(:params) { {
          'servername'    => 'versions.publiq.dev',
          'serveraliases' => 'foo.example.com',
          'deployment'    => false
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to_not contain_class('profiles::publiq::versions::deployment') }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://versions.publiq.dev').with(
          'destination' => 'http://127.0.0.1:3000/',
          'aliases'     => 'foo.example.com'
        ) }
      end

      context "with servername => myversions.publiq.dev and serveraliases => [bar.example.com, baz.example.com]" do
        let(:params) { {
          'servername'    => 'myversions.publiq.dev',
          'serveraliases' => ['bar.example.com', 'baz.example.com']
        } }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://myversions.publiq.dev').with(
          'destination' => 'http://127.0.0.1:3000/',
          'aliases'     => ['bar.example.com', 'baz.example.com']
        ) }
      end

      context "without parameters" do
        let(:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
