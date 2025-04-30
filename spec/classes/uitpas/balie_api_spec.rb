describe 'profiles::uitpas::balie_api' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with servername => balie_api.example.com and balie_next_url => http://balie-next.example.com" do
        let(:params) { {
          'servername'     => 'balie_api.example.com',
          'balie_next_url' => 'http://balie-next.example.com'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitpas::balie_api').with(
            'servername'     => 'balie_api.example.com',
            'balie_next_url' => 'http://balie-next.example.com',
            'serveraliases'  => [],
            'deployment'     => true
          ) }

          it { is_expected.to contain_class('profiles::uitpas::balie_api::deployment') }

          it { is_expected.to contain_class('profiles::php') }
          it { is_expected.to contain_class('apache::mod::proxy') }
          it { is_expected.to contain_class('apache::mod::proxy_http') }

          it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://balie_api.example.com').with(
            'aliases'              => [],
            'basedir'              => '/var/www/uitpas-balie-api',
            'public_web_directory' => 'web',
            'ssl_proxyengine'      => false,
            'headers'              => 'set Cache-Control "no-cache,no-store" "env=legacy_app_path"',
            'directories'          => {
                                        'path'     => '/app_v1/index.html',
                                        'provider' => 'files',
                                        'headers'  => [
                                                        'set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"',
                                                        'set Pragma "no-cache"',
                                                        'set Expires "Wed, 1 Jan 1970 00:00:00 GMT"'
                                                      ]
                                      },
            'rewrites'             => [
                                        {
                                          'comment'      => 'Redirect ROOT to angular app with path /app_v1/ if it exists',
                                          'rewrite_cond' => '%{DOCUMENT_ROOT}/app_v1 -d',
                                          'rewrite_rule' => '^/$ /app_v1/ [R]'
                                        }, {
                                          'comment'      => 'Set legacy environment variable for all paths starting wit /app_v1/',
                                          'rewrite_cond' => '%{REQUEST_URI} ^/app_v1/.*$',
                                          'rewrite_rule' => '^ - [E=legacy_app_path]'
                                        }, {
                                          'comment'      => 'Redirect /mobile to /app/mobile',
                                          'rewrite_rule' => '^/mobile /app/mobile [L,R=301]'
                                        }, {
                                          'comment'      => 'Proxy /app to React app',
                                          'rewrite_rule' => '^/app$ http://balie-next.example.com/app [P,L]'
                                        }, {
                                          'comment'      => 'Proxy /app/ to React app',
                                          'rewrite_rule' => '^/app/(.*)$ http://balie-next.example.com/app/$1 [P,L]'
                                        }
                                      ]
          ) }
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context "with servername => test.example.com, balie_next_url => 'https://next.example.com and serveraliases => alias.example.com" do
        let(:params) { {
          'servername'     => 'test.example.com',
          'balie_next_url' => 'https://next.example.com',
          'serveraliases'  => 'alias.example.com'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://test.example.com').with(
            'aliases'              => 'alias.example.com',
            'basedir'              => '/var/www/uitpas-balie-api',
            'public_web_directory' => 'web',
            'ssl_proxyengine'      => true,
            'headers'              => 'set Cache-Control "no-cache,no-store" "env=legacy_app_path"',
            'directories'          => {
                                        'path'     => '/app_v1/index.html',
                                        'provider' => 'files',
                                        'headers'  => [
                                                        'set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"',
                                                        'set Pragma "no-cache"',
                                                        'set Expires "Wed, 1 Jan 1970 00:00:00 GMT"'
                                                      ]
                                      },
            'rewrites'             => [
                                        {
                                          'comment'      => 'Redirect ROOT to angular app with path /app_v1/ if it exists',
                                          'rewrite_cond' => '%{DOCUMENT_ROOT}/app_v1 -d',
                                          'rewrite_rule' => '^/$ /app_v1/ [R]'
                                        }, {
                                          'comment'      => 'Set legacy environment variable for all paths starting wit /app_v1/',
                                          'rewrite_cond' => '%{REQUEST_URI} ^/app_v1/.*$',
                                          'rewrite_rule' => '^ - [E=legacy_app_path]'
                                        }, {
                                          'comment'      => 'Redirect /mobile to /app/mobile',
                                          'rewrite_rule' => '^/mobile /app/mobile [L,R=301]'
                                        }, {
                                          'comment'      => 'Proxy /app to React app',
                                          'rewrite_rule' => '^/app$ https://next.example.com/app [P,L]'
                                        }, {
                                          'comment'      => 'Proxy /app/ to React app',
                                          'rewrite_rule' => '^/app/(.*)$ https://next.example.com/app/$1 [P,L]'
                                        }
                                      ]
          ) }
        end

        context 'with deployment => false' do
          let(:params) {
            super().merge({ 'deployment' => false })
          }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to_not contain_class('profiles::uitpas::balie_api::deployment') }
        end
      end
    end
  end
end
