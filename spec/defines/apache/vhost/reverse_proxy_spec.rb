describe 'profiles::apache::vhost::reverse_proxy' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on node node1.example.com" do
        let(:node) { 'node1.example.com' }

        context "with title => http://leonardo.example.com" do
          let(:title) { 'http://leonardo.example.com' }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            context "with destination => http://davinci.example.com and aliases => leo.example.com" do
              let(:params) { {
                'destination' => 'http://davinci.example.com/',
                'aliases'     => 'leo.example.com'
              } }

              it { is_expected.to compile.with_all_deps }

              it { is_expected.to contain_firewall('300 accept HTTP traffic') }

              it { is_expected.not_to contain_class('apache::mod::ssl') }

              it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://leonardo.example.com').with(
                'destination'           => 'http://davinci.example.com/',
                'certificate'           => nil,
                'preserve_host'         => false,
                'allow_encoded_slashes' => 'off',
                'aliases'               => 'leo.example.com',
                'proxy_keywords'        => [],
                'proxy_params'          => {},
                'support_websockets'    => false,
                'auth_openid_connect'   => false,
                'access_log_format'     => 'extended_json'
              ) }

              it { is_expected.to contain_apache__vhost('leonardo.example.com_80').with(
                'servername'            => 'leonardo.example.com',
                'serveraliases'         => ['leo.example.com'],
                'docroot'               => '/var/www/html',
                'manage_docroot'        => false,
                'port'                  => 80,
                'ssl'                   => false,
                'ssl_proxyengine'       => false,
                'request_headers'       => [
                                             'unset Proxy early',
                                             'set X-Unique-Id %{UNIQUE_ID}e',
                                             'setifempty X-Forwarded-Port "80"',
                                             'setifempty X-Forwarded-Proto "http"'
                                           ],
                'access_log_format'     => 'extended_json',
                'auth_oidc'             => false,
                'oidc_settings'         => {},
                'directories'           => [],
                'setenvif'              => [
                                             'X-Forwarded-Proto "https" HTTPS=on',
                                             'X-Forwarded-For "^([^,]*),?.*" CLIENT_IP=$1'
                                           ],
                'allow_encoded_slashes' => 'off',
                'proxy_preserve_host'   => false,
                'rewrites'              => [],
                'proxy_pass'            => {
                                             'path'          => '/',
                                             'url'           => 'http://davinci.example.com/',
                                             'keywords'      => [],
                                             'reverse_urls'  => 'http://davinci.example.com/',
                                             'params'        => {},
                                             'no_proxy_uris' => []
                                           }
              ) }
            end

            context "with destination => http://davinci.example.com, proxy_params => { 'connectiontimeout' => 5 }, auth_openid_connect => true, access_log_format => combined_json and support_websockets => true" do
              let(:params) { {
                'destination'         => 'http://davinci.example.com/',
                'proxy_params'        => { 'connectiontimeout' => 5 },
                'auth_openid_connect' => true,
                'support_websockets'  => true,
                'access_log_format'   => 'combined_json'
              } }

              it { is_expected.to contain_class('apache::mod::proxy_wstunnel') }
              it { is_expected.to contain_class('apache::mod::authn_core') }
              it { is_expected.not_to contain_class('apache::mod::ssl') }

              it { is_expected.to contain_apache__vhost('leonardo.example.com_80').with(
                'servername'            => 'leonardo.example.com',
                'docroot'               => '/var/www/html',
                'manage_docroot'        => false,
                'port'                  => 80,
                'ssl'                   => false,
                'ssl_proxyengine'       => false,
                'request_headers'       => [
                                             'unset Proxy early',
                                             'set X-Unique-Id %{UNIQUE_ID}e',
                                             'setifempty X-Forwarded-Port "80"',
                                             'setifempty X-Forwarded-Proto "http"'
                                           ],
                'access_log_format'     => 'combined_json',
                'auth_oidc'             => true,
                'directories'           => [{
                                             'path'      => '/',
                                             'provider'  => 'location',
                                             'auth_type' => 'openid-connect',
                                             'require'   => 'valid-user'
                                           }],
                'oidc_settings'         => {
                                             'ProviderMetadataURL' => 'https://openid.example.com/.well-known/openid-configuration',
                                             'ClientID'            => 'abc123',
                                             'ClientSecret'        => 'def456',
                                             'RedirectURI'         => 'https://leonardo.example.com/redirect_uri',
                                             'CryptoPassphrase'    => 'a3Tl84mHAFP1DoOvMDESaXyXcUsC2cPu'
                                           },
                'setenvif'              => [
                                             'X-Forwarded-Proto "https" HTTPS=on',
                                             'X-Forwarded-For "^([^,]*),?.*" CLIENT_IP=$1'
                                           ],
                'allow_encoded_slashes' => 'off',
                'proxy_preserve_host'   => false,
                'rewrites'              => [{
                                             'comment'      => 'Proxy Websocket support',
                                             'rewrite_cond' => ['%{HTTP:Upgrade} =websocket [NC]'],
                                             'rewrite_rule' => '^/(.*) ws://davinci.example.com/$1 [P,L]'
                                           }],
                'proxy_pass'            => {
                                             'path'          => '/',
                                             'url'           => 'http://davinci.example.com/',
                                             'keywords'      => [],
                                             'reverse_urls'  => 'http://davinci.example.com/',
                                             'params'        => { 'connectiontimeout' => 5 },
                                             'no_proxy_uris' => ['/redirect_uri']
                                           }
              ) }
            end
          end

          context "without hieradata" do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            context "with destination => http://davinci.example.com, auth_openid_connect => true and aliases => leo.example.com" do
              let(:params) { {
                'destination'         => 'http://davinci.example.com/',
                'auth_openid_connect' => true,
                'aliases'             => 'leo.example.com'
              } }

              it { expect { catalogue }.to raise_error(Puppet::ParseError, /parameter 'oidc_settings' entry 'ProviderMetadataURL' expects/) }
              it { expect { catalogue }.to raise_error(Puppet::ParseError, /parameter 'oidc_settings' entry 'ClientID' expects/) }
              it { expect { catalogue }.to raise_error(Puppet::ParseError, /parameter 'oidc_settings' entry 'ClientSecret' expects/) }
            end
          end
        end

        context "with title => https://michelangelo.example.com" do
          let(:title) { 'https://michelangelo.example.com' }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            context "with certificate => 'foobar.example.com', destination => https://buonarotti.example.com/, preserve_host => true, allow_encoded_slashes => nodecode, proxy_keywords => ['interpolate', 'noquery'], support_websockets => true, proxy_params => {'timeout' => 300, 'ping' => 3} and aliases => ['mich.example.com', 'angelo.example.com']" do
              let(:params) { {
                'certificate'           => 'foobar.example.com',
                'destination'           => 'https://buonarotti.example.com/',
                'preserve_host'         => true,
                'allow_encoded_slashes' => 'nodecode',
                'support_websockets'    => true,
                'proxy_keywords'        => ['interpolate', 'noquery'],
                'proxy_params'          => {'timeout' => 300, 'ping' => 3},
                'aliases'               => ['mich.example.com', 'angelo.example.com']
              } }

              it { is_expected.to contain_firewall('300 accept HTTPS traffic') }

              it { is_expected.to contain_profiles__certificate('foobar.example.com') }

              it { is_expected.to contain_class('apache::mod::proxy_wstunnel') }
              it { is_expected.to contain_class('apache::mod::ssl') }

              it { is_expected.to contain_apache__vhost('michelangelo.example.com_443').with(
                'servername'            => 'michelangelo.example.com',
                'serveraliases'         => ['mich.example.com', 'angelo.example.com'],
                'port'                  => 443,
                'access_log_format'     => 'extended_json',
                'setenvif'              => [
                                             'X-Forwarded-Proto "https" HTTPS=on',
                                             'X-Forwarded-For "^([^,]*),?.*" CLIENT_IP=$1'
                                           ],
                'ssl'                   => true,
                'ssl_cert'              => '/etc/ssl/certs/foobar.example.com.bundle.crt',
                'ssl_key'               => '/etc/ssl/private/foobar.example.com.key',
                'ssl_proxyengine'       => true,
                'request_headers'       => [
                                             'unset Proxy early',
                                             'set X-Unique-Id %{UNIQUE_ID}e',
                                             'setifempty X-Forwarded-Port "443"',
                                             'setifempty X-Forwarded-Proto "https"'
                                           ],
                'proxy_preserve_host'   => true,
                'allow_encoded_slashes' => 'nodecode',
                'auth_oidc'             => false,
                'directories'           => [],
                'oidc_settings'         => {},
                'rewrites'              => [{
                                             'comment'      => 'Proxy Websocket support',
                                             'rewrite_cond' => ['%{HTTP:Upgrade} =websocket [NC]'],
                                             'rewrite_rule' => '^/(.*) wss://buonarotti.example.com/$1 [P,L]'
                                           }],
                'proxy_pass'            => {
                                             'path'          => '/',
                                             'url'           => 'https://buonarotti.example.com/',
                                             'keywords'      => ['interpolate', 'noquery'],
                                             'reverse_urls'  => ['https://buonarotti.example.com/', 'http://michelangelo.example.com/'],
                                             'params'        => { 'timeout' => 300, 'ping' => 3 },
                                             'no_proxy_uris' => []
                                           }
              ) }

              it { is_expected.to contain_profiles__certificate('foobar.example.com').that_comes_before('Apache::Vhost[michelangelo.example.com_443]') }
              it { is_expected.to contain_profiles__certificate('foobar.example.com').that_notifies('Class[apache::service]') }
            end

            context "with destination => https://buonarotti.example.com" do
              let(:params) { {
                'destination' => 'https://buonarotti.example.com'
              } }

              it { expect { catalogue }.to raise_error(Puppet::Error, /expects a value for parameter certificate when using HTTPS/) }
            end

            context "without parameters" do
              let(:params) { {} }

              it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'destination'/) }
            end
          end
        end
      end

      context 'on node mynode.example.com' do
        let(:node) { 'mynode.example.com' }

        context "with title => http://raphael.example.com/" do
          let(:title) { 'http://raphael.example.com/' }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            context "with destination => https://buonarotti.example.com/ and auth_openid_connect => true" do
              let(:params) { {
                'destination'         => 'https://buonarotti.example.com/',
                'auth_openid_connect' => true
              } }

              it { is_expected.to contain_class('apache::mod::authn_core') }
              it { is_expected.to contain_class('apache::mod::ssl') }

              it { is_expected.to contain_apache__vhost('raphael.example.com_80').with(
                'servername'            => 'raphael.example.com',
                'serveraliases'         => [],
                'docroot'               => '/var/www/html',
                'manage_docroot'        => false,
                'port'                  => 80,
                'access_log_format'     => 'extended_json',
                'setenvif'              => [
                                             'X-Forwarded-Proto "https" HTTPS=on',
                                             'X-Forwarded-For "^([^,]*),?.*" CLIENT_IP=$1'
                                           ],
                'auth_oidc'             => true,
                'directories'           => [{
                                             'path'      => '/',
                                             'provider'  => 'location',
                                             'auth_type' => 'openid-connect',
                                             'require'   => 'valid-user'
                                           }],
                'oidc_settings'         => {
                                             'ProviderMetadataURL' => 'https://openid.example.com/.well-known/openid-configuration',
                                             'ClientID'            => 'abc123',
                                             'ClientSecret'        => 'def456',
                                             'RedirectURI'         => 'https://raphael.example.com/redirect_uri',
                                             'CryptoPassphrase'    => 'eFRxI8X8h4zOZ9Die6UEoqkbbzKJ4xvP'
                                           },
                'ssl'                   => false,
                'ssl_proxyengine'       => true,
                'request_headers'       => [
                                             'unset Proxy early',
                                             'set X-Unique-Id %{UNIQUE_ID}e',
                                             'setifempty X-Forwarded-Port "80"',
                                             'setifempty X-Forwarded-Proto "http"'
                                           ],
                'allow_encoded_slashes' => 'off',
                'proxy_preserve_host'   => false,
                'rewrites'              => [],
                'proxy_pass'            => {
                                             'path'          => '/',
                                             'url'           => 'https://buonarotti.example.com/',
                                             'keywords'      => [],
                                             'reverse_urls'  => 'https://buonarotti.example.com/',
                                             'params'        => {},
                                             'no_proxy_uris' => ['/redirect_uri']
                                           }
              ) }
            end
          end
        end

        context "with title => leonardo.example.com" do
          let(:title) { 'leonardo.example.com' }

          context "with destination => http://buonarotti.example.com" do
            let(:params) { {
              'destination' => 'http://buonarotti.example.com',
            } }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects the title to be a valid HTTP\(S\) URL/) }
          end
        end
      end
    end
  end
end
