describe 'profiles::uitdatabank::angular_app' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with servername => app.example.com' do
        let(:params) { {
          'servername' => 'app.example.com'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'without extra parameters' do
            let(:params) { super().merge({}) }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitdatabank::angular_app').with(
              'servername'      => 'app.example.com',
              'serveraliases'   => [],
              'deployment'      => true
            ) }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }

            it { is_expected.to contain_file('/var/www/udb3-angular-app').with(
              'ensure' => 'directory',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.to contain_class('profiles::apache') }

            it { is_expected.to contain_apache__mod('access_compat') }

            it { is_expected.to contain_profiles__apache__vhost__basic('http://app.example.com').with(
              'serveraliases' => [],
              'documentroot'  => '/var/www/udb3-angular-app',
              'directories'   => [{
                                   'path'     => 'index.html',
                                   'provider' => 'files',
                                   'headers'  => [
                                                   'set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"',
                                                   'set Pragma "no-cache"',
                                                   'set Expires "Wed, 1 Jan 1970 00:00:00 GMT"'
                                                 ]
                                 }]
            ) }

            it { is_expected.to contain_class('profiles::uitdatabank::angular_app::deployment') }

            it { is_expected.to contain_file('/var/www/udb3-angular-app').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('/var/www/udb3-angular-app').that_requires('User[www-data]') }
            it { is_expected.to contain_file('/var/www/udb3-angular-app').that_requires('Class[profiles::apache]') }
          end

          context 'with deployment => false' do
            let(:params) { super().merge({
              'deployment' => false
            }) }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::apache') }

            it { is_expected.to_not contain_class('profiles::uitdatabank::angular_app::deployment') }
          end
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context 'with servername => angular.example.com and serveraliases => [www.example.com, old.example.com]' do
        let(:params) { {
          'servername'    => 'angular.example.com',
          'serveraliases' => ['www.example.com', 'old.example.com']
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__apache__vhost__basic('http://angular.example.com').with(
            'serveraliases' => ['www.example.com', 'old.example.com'],
            'documentroot'  => '/var/www/udb3-angular-app',
            'directories'   => [{
                                 'path'     => 'index.html',
                                 'provider' => 'files',
                                 'headers'  => [
                                                 'set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"',
                                                 'set Pragma "no-cache"',
                                                 'set Expires "Wed, 1 Jan 1970 00:00:00 GMT"'
                                               ]
                               }]
          ) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
