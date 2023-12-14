describe 'profiles::publiq::versions' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with url => 'http://versions.local'" do
        let(:params) { {
          'url'          => 'http://versions.local'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::publiq::versions').with(
          'url'             => 'http://versions.local',
          'deployment'      => true,
          'service_address' => '127.0.0.1',
          'service_port'    => '3000'
        ) }

        it { is_expected.to contain_class('profiles::ruby') }

        it { is_expected.to contain_class('profiles::publiq::versions::deployment') }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://versions.local').with(
          'destination' => 'http://127.0.0.1:3000/'
        ) }

        it { is_expected.to contain_class('profiles::publiq::versions::deployment').that_requires('Class[profiles::ruby]') }

        context "with service_address => 0.0.0.0 and service_port => 5000" do
          let(:params)  { super().merge( {
              'service_address' => '0.0.0.0',
              'service_port'    => 5000
          } ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://versions.local').with(
            'destination' => 'http://0.0.0.0:5000/'
          ) }
        end
      end

      context "with url => http://versions.publiq.dev and deployment => false" do
        let(:params) { {
          'url'          => 'http://versions.publiq.dev',
          'deployment'   => false
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::ruby') }
        it { is_expected.to_not contain_class('profiles::publiq::versions::deployment') }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://versions.publiq.dev').with(
          'destination' => 'http://127.0.0.1:3000/'
        ) }
      end

      context "without parameters" do
        let(:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'url'/) }
      end
    end
  end
end
