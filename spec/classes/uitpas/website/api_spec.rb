describe 'profiles::uitpas::website::api' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with servername => uitpas-backend.example.com' do
        let(:params) { {
          'servername' => 'uitpas-backend.example.com'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'without extra parameters' do
            let(:params) {
              super().merge({})
            }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::website::api').with(
              'servername'    => 'uitpas-backend.example.com',
              'serveraliases' => [],
              'deployment'    => true
            ) }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }

            it { is_expected.to contain_class('profiles::apache') }

            it { is_expected.to contain_file('/var/www/uitpas-website-api').with(
              'ensure' => 'directory',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.to contain_class('profiles::uitpas::website::api::deployment') }

            it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://uitpas-backend.example.com').with(
              'basedir'              => '/var/www/uitpas-website-api',
              'public_web_directory' => 'public',
              'aliases'              => []
            ) }

            it { is_expected.to contain_file('/var/www/uitpas-website-api').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('/var/www/uitpas-website-api').that_requires('User[www-data]') }
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
