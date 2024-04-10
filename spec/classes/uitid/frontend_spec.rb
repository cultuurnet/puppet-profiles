describe 'profiles::uitid::frontend' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with servername => foo.example.com" do
        let(:params) { {
          'servername' => 'foo.example.com'
        } }

        context "without extra parameters" do
          let(:params) {
            super().merge({})
          }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitid::frontend').with(
              'servername'      => 'foo.example.com',
              'serveraliases'   => [],
              'deployment'      => true,
              'service_address' => '127.0.0.1',
              'service_port'    => 3000
            ) }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }
            it { is_expected.to contain_firewall('300 accept HTTP traffic') }

            it { is_expected.to contain_class('profiles::nodejs') }
            it { is_expected.to contain_class('profiles::apache') }

            it { is_expected.to contain_file('/var/www/uitid-frontend').with(
              'ensure' => 'directory',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.to contain_class('profiles::uitid::frontend::deployment').with(
              'service_address' => '127.0.0.1',
              'service_port'    => 3000
            ) }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://foo.example.com').with(
              'destination' => 'http://127.0.0.1:3000/',
              'aliases'     => []
            ) }

            it { is_expected.to contain_file('/var/www/uitid-frontend').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('/var/www/uitid-frontend').that_requires('User[www-data]') }
            it { is_expected.to contain_class('profiles::uitid::frontend::deployment').that_requires('Class[profiles::nodejs]') }
            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://foo.example.com').that_requires('Class[profiles::uitid::frontend::deployment]') }
            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://foo.example.com').that_requires('Class[profiles::apache]') }
            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://foo.example.com').that_requires('File[/var/www/uitid-frontend]') }
          end

          context "without hieradata" do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
          end
        end

        context "with service_address => 127.0.1.1 and service_port => 7000" do
          let(:params) {
            super().merge( {
              'service_address' => '127.0.1.1',
              'service_port'    => 7000
            } )
          }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitid::frontend::deployment').with(
              'service_address' => '127.0.1.1',
              'service_port'    => 7000
            ) }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://foo.example.com').with(
              'destination' => 'http://127.0.1.1:7000/',
              'aliases'     => []
            ) }
          end
        end

        context "with deployment => false" do
          let(:params) {
            super().merge( {
              'deployment' => false
            } )
          }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::nodejs') }
          it { is_expected.to contain_class('profiles::apache') }
          it { is_expected.to_not contain_class('profiles::uitid::frontend::deployment') }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://foo.example.com').with(
            'destination' => 'http://127.0.0.1:3000/',
            'aliases'     => []
          ) }
        end
      end

      context "with servername => bar.example.com" do
        let(:params) { {
          'servername' => 'bar.example.com'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }


          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').with(
            'destination' => 'http://127.0.0.1:3000/',
            'aliases'     => []
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').that_requires('Class[profiles::uitid::frontend::deployment]') }
          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').that_requires('Class[profiles::apache]') }
          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').that_requires('File[/var/www/uitid-frontend]') }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
