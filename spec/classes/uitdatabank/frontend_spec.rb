describe 'profiles::uitdatabank::frontend' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with servername => frontend.example.com' do
        let(:params) { {
          'servername' => 'frontend.example.com'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'without extra parameters' do
            let(:params) { super().merge({}) }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitdatabank::frontend').with(
              'servername'      => 'frontend.example.com',
              'serveraliases'   => [],
              'deployment'      => true,
              'service_address' => '127.0.0.1',
              'service_port'    => 4000
            ) }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }

            it { is_expected.to contain_file('/var/www/udb3-frontend').with(
              'ensure' => 'directory',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.to contain_class('profiles::nodejs') }
            it { is_expected.to contain_class('profiles::apache') }

            it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment').with(
              'service_address' => '127.0.0.1',
              'service_port'    => 4000
            ) }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://frontend.example.com').with(
              'aliases'     => [],
              'destination' => 'http://127.0.0.1:4000/'
            ) }

            it { is_expected.to contain_file('/var/www/udb3-frontend').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('/var/www/udb3-frontend').that_requires('User[www-data]') }
            it { is_expected.to contain_file('/var/www/udb3-frontend').that_requires('Class[profiles::apache]') }
            it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment').that_requires('Class[profiles::nodejs]') }
            it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment').that_comes_before('Profiles::Apache::Vhost::Reverse_proxy[http://frontend.example.com]') }
          end

          context 'with serveraliases => [foo.example.com, bar.example.com], service_address => 0.0.0.0 and service_port => 4567' do
            let(:params) { super().merge({
              'serveraliases'   => ['foo.example.com', 'bar.example.com'],
              'service_address' => '0.0.0.0',
              'service_port'    => 4567
            }) }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment').with(
              'service_address' => '0.0.0.0',
              'service_port'    => 4567
            ) }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://frontend.example.com').with(
              'aliases'     => ['foo.example.com', 'bar.example.com'],
              'destination' => 'http://0.0.0.0:4567/'
            ) }
          end

          context 'with deployment => false' do
            let(:params) { super().merge({
              'deployment' => false
            }) }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::nodejs') }
            it { is_expected.to contain_class('profiles::apache') }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://frontend.example.com').with(
              'aliases'     => [],
              'destination' => 'http://127.0.0.1:4000/'
            ) }

            it { is_expected.to_not contain_class('profiles::uitdatabank::frontend::deployment') }
          end
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
