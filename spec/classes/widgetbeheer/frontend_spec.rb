describe 'profiles::widgetbeheer::frontend' do
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

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::widgetbeheer::frontend').with(
            'servername'      => 'frontend.example.com',
            'serveraliases'   => [],
            'deployment'      => true
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_file('/var/www/widgetbeheer-frontend').with(
            'ensure' => 'directory',
            'owner'  => 'www-data',
            'group'  => 'www-data'
          ) }

          it { is_expected.to contain_class('profiles::apache') }

          it { is_expected.to contain_class('profiles::widgetbeheer::frontend::deployment') }

          it { is_expected.to contain_profiles__apache__vhost__basic('http://frontend.example.com').with(
            'serveraliases' => [],
            'documentroot'  => '/var/www/widgetbeheer-frontend',
            'rewrites'      => {
                                 'comment'      => 'Send all requests through index.html',
                                 'rewrite_cond' => [
                                                     '/var/www/widgetbeheer-frontend%{REQUEST_FILENAME} !-f',
                                                     '/var/www/widgetbeheer-frontend%{REQUEST_FILENAME} !-d'
                                                   ],
                                 'rewrite_rule' => '. /index.html [L]'
                               }
          ) }

          it { is_expected.to contain_file('/var/www/widgetbeheer-frontend').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/var/www/widgetbeheer-frontend').that_requires('User[www-data]') }
          it { is_expected.to contain_file('/var/www/widgetbeheer-frontend').that_requires('Class[profiles::apache]') }
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context 'with servername => widgets.example.com, serveraliases => [foo.example.com, bar.example.com], deployment => false' do
        let(:params) { {
          'servername'    => 'widgets.example.com',
          'serveraliases' => ['foo.example.com', 'bar.example.com'],
          'deployment'    => false
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__apache__vhost__basic('http://widgets.example.com').with(
            'serveraliases' => ['foo.example.com', 'bar.example.com'],
            'documentroot'  => '/var/www/widgetbeheer-frontend',
            'rewrites'      => {
                                 'comment'      => 'Send all requests through index.html',
                                 'rewrite_cond' => [
                                                     '/var/www/widgetbeheer-frontend%{REQUEST_FILENAME} !-f',
                                                     '/var/www/widgetbeheer-frontend%{REQUEST_FILENAME} !-d'
                                                   ],
                                 'rewrite_rule' => '. /index.html [L]'
                               }
          ) }

          it { is_expected.to_not contain_class('profiles::uitdatabank::frontend::deployment') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
