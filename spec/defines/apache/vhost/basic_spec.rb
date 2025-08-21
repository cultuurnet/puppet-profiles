describe 'profiles::apache::vhost::basic' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with title => http://www.example.com' do
        let(:title) { 'http://www.example.com' }

        context 'without parameters' do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__apache__vhost__basic('http://www.example.com').with(
            'serveraliases'       => [],
            'documentroot'        => '/var/www/html',
            'access_log_format'   => 'extended_json',
            'directories'         => [],
            'auth_openid_connect' => false,
            'ssl_proxyengine'     => false
          ) }

          it { is_expected.to contain_firewall('300 accept HTTP traffic') }

          it { is_expected.not_to contain_class('apache::mod::proxy_http') }
          it { is_expected.not_to contain_class('apache::mod::ssl') }

          it { is_expected.to contain_apache__vhost('www.example.com_80').with(
            'servername'         => 'www.example.com',
            'serveraliases'      => [],
            'docroot'            => '/var/www/html',
            'manage_docroot'     => false,
            'port'               => 80,
            'ssl'                => false,
            'request_headers'    => [
                                      'unset Proxy early',
                                      'set X-Unique-Id %{UNIQUE_ID}e',
                                      'setifempty X-Forwarded-Port "80"',
                                      'setifempty X-Forwarded-Proto "http"'
                                    ],
            'access_log_format'  => 'extended_json',
            'access_log_env_var' => '!nolog',
            'setenvif'           => [
                                      'X-Forwarded-Proto "https" HTTPS=on',
                                      'X-Forwarded-For "^([^,]*),?.*" CLIENT_IP=$1'
                                    ],
            'directories'        => [
                                      {
                                        'path'           => '/var/www/html',
                                        'options'        => ['Indexes', 'FollowSymLinks', 'MultiViews'],
                                        'allow_override' => 'All'
                                      }
                                    ],
            'ssl_proxyengine'    => false
          ) }
        end

        context 'with serveraliases => [web.example.com, test.example.com], documentroot => /var/www/bar, access_log_format => extended and directories => { path => secret_file.html, provider => files, deny => from all }' do
          let(:params) { {
            'serveraliases'       => ['web.example.com', 'test.example.com'],
            'documentroot'        => '/var/www/bar',
            'access_log_format'   => 'extended',
            'directories'         => {
                                       'path'     => 'secret_file.html',
                                       'provider' => 'files',
                                       'deny'     => 'from all'
                                     }
          } }

          it { is_expected.to contain_apache__vhost('www.example.com_80').with(
            'servername'         => 'www.example.com',
            'serveraliases'      => ['web.example.com', 'test.example.com'],
            'docroot'            => '/var/www/bar',
            'manage_docroot'     => false,
            'port'               => 80,
            'ssl'                => false,
            'auth_oidc'          => false,
            'oidc_settings'      => {},
            'request_headers'    => [
                                      'unset Proxy early',
                                      'set X-Unique-Id %{UNIQUE_ID}e',
                                      'setifempty X-Forwarded-Port "80"',
                                      'setifempty X-Forwarded-Proto "http"'
                                    ],
            'access_log_format'  => 'extended',
            'access_log_env_var' => '!nolog',
            'setenvif'           => [
                                      'X-Forwarded-Proto "https" HTTPS=on',
                                      'X-Forwarded-For "^([^,]*),?.*" CLIENT_IP=$1'
                                    ],
            'directories'        => [
                                      {
                                        'path'           => '/var/www/bar',
                                        'options'        => ['Indexes', 'FollowSymLinks', 'MultiViews'],
                                        'allow_override' => 'All'
                                      },
                                      {
                                       'path'     => 'secret_file.html',
                                       'provider' => 'files',
                                       'deny'     => 'from all'
                                      }
                                    ]
          ) }
        end

        context 'with auth_openid_connect => true' do
          let(:params) { {
            'auth_openid_connect' => true
          } }

          context 'without hieradata' do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /parameter 'oidc_settings' entry 'ProviderMetadataURL' expects/) }
            it { expect { catalogue }.to raise_error(Puppet::ParseError, /parameter 'oidc_settings' entry 'ClientID' expects/) }
            it { expect { catalogue }.to raise_error(Puppet::ParseError, /parameter 'oidc_settings' entry 'ClientSecret' expects/) }
          end
        end
      end

      context 'with title => https://myvhost.example.com' do
        let(:title) { 'https://myvhost.example.com' }

        context 'on node mynode.example.com' do
          let(:node) { 'mynode.example.com' }

          context 'with hieradata' do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            context 'without parameters' do
              let(:params) { {} }

              it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter certificate when using HTTPS/) }
            end

            context 'with serveraliases => foobar.example.com, certificate => wildcard.example.com, documentroot => /var/www/foobar, auth_openid_connect => true, directories => [ { path => /path/to/directory, handler => value }, { path => /path/to/other/directory, handler => othervalue } ], rewrites => { comment => Proxy to foo.example.com, rewrite_rule => ^(.*)$ https://foo.example.com/$1 [P] } and ssl_proxyengine => true' do
              let(:params) { {
                'serveraliases'       => 'foobar.example.com',
                'certificate'         => 'wildcard.example.com',
                'documentroot'        => '/var/www/foobar',
                'auth_openid_connect' => true,
                'directories'         => [
                                           { 'path' => '/path/to/directory', 'handler' => 'value' },
                                           { 'path' => '/path/to/other/directory', 'handler' => 'othervalue' }
                                         ],
                'rewrites'            => {
                                           'comment'      => 'Proxy to foo.example.com',
                                           'rewrite_rule' => '^(.*)$ https://foo.example.com/$1 [P]'
                                         },
                'ssl_proxyengine'     => true
              } }

              it { is_expected.to contain_firewall('300 accept HTTPS traffic') }

              it { is_expected.to contain_profiles__certificate('wildcard.example.com') }

              it { is_expected.to contain_class('apache::mod::authn_core') }
              it { is_expected.to contain_class('apache::mod::proxy_http') }
              it { is_expected.to contain_class('apache::mod::ssl') }

              it { is_expected.to contain_apache__vhost('myvhost.example.com_443').with(
                'servername'         => 'myvhost.example.com',
                'serveraliases'      => 'foobar.example.com',
                'docroot'            => '/var/www/foobar',
                'manage_docroot'     => false,
                'port'               => 443,
                'ssl'                => true,
                'ssl_cert'           => '/etc/ssl/certs/wildcard.example.com.bundle.crt',
                'ssl_key'            => '/etc/ssl/private/wildcard.example.com.key',
                'request_headers'    => [
                                          'unset Proxy early',
                                          'set X-Unique-Id %{UNIQUE_ID}e',
                                          'setifempty X-Forwarded-Port "443"',
                                          'setifempty X-Forwarded-Proto "https"'
                                        ],
                'access_log_format'  => 'extended_json',
                'access_log_env_var' => '!nolog',
                'setenvif'           => [
                                          'X-Forwarded-Proto "https" HTTPS=on',
                                          'X-Forwarded-For "^([^,]*),?.*" CLIENT_IP=$1'
                                        ],
                'auth_oidc'          => true,
                'oidc_settings'      => {
                                          'ProviderMetadataURL' => 'https://openid.example.com/.well-known/openid-configuration',
                                          'ClientID'            => 'abc123',
                                          'ClientSecret'        => 'def456',
                                          'RedirectURI'         => 'https://myvhost.example.com/redirect_uri',
                                          'CryptoPassphrase'    => 'eFRxI8X8h4zOZ9Die6UEoqkbbzKJ4xvP'
                                        },
                'directories'        => [
                                          {
                                            'path'      => '/',
                                            'provider'  => 'location',
                                            'auth_type' => 'openid-connect',
                                            'require'   => 'valid-user'
                                          },
                                          {
                                            'path'           => '/var/www/foobar',
                                            'options'        => ['Indexes', 'FollowSymLinks', 'MultiViews'],
                                            'allow_override' => 'All'
                                          },
                                          {
                                            'path'    => '/path/to/directory',
                                            'handler' => 'value'
                                          },
                                          {
                                            'path'    => '/path/to/other/directory',
                                            'handler' => 'othervalue'
                                          }
                                        ],
                'rewrites'           => [{
                                          'comment'      => 'Proxy to foo.example.com',
                                          'rewrite_rule' => '^(.*)$ https://foo.example.com/$1 [P]'
                                        }],
                'ssl_proxyengine'    => true
              ) }
            end
          end
        end
      end
    end
  end
end
