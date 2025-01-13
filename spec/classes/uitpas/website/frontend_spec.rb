describe 'profiles::uitpas::website::frontend' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with servername => uitpas.example.com' do
        let(:params) { {
          'servername' => 'uitpas.example.com'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'without extra parameters' do
            let(:params) {
              super().merge({})
            }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::website::frontend').with(
              'servername'    => 'uitpas.example.com',
              'serveraliases' => [],
              'deployment'    => true
            ) }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }

            it { is_expected.to contain_class('profiles::apache') }

            it { is_expected.to contain_file('/var/www/uitpas-website-frontend').with(
              'ensure' => 'directory',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.to contain_class('profiles::uitpas::website::frontend::deployment') }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://uitpas.example.com').with(
              'destination' => 'http://127.0.0.1:3000/',
              'aliases'              => [],
            ) }

            it { is_expected.to contain_file('/var/www/uitpas-website-frontend').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('/var/www/uitpas-website-frontend').that_requires('User[www-data]') }
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
