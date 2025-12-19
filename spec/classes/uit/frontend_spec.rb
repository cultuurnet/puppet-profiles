describe 'profiles::uit::frontend' do
  context "with servername => foo.example.com" do
    let(:params) { {
      'servername' => 'foo.example.com'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "without extra parameters" do
          let(:params) {
            super().merge({})
          }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uit::frontend').with(
              'servername'          => 'foo.example.com',
              'serveraliases'       => [],
              'deployment'          => true,
              'service_address'     => '127.0.0.1',
              'service_port'        => 3000,
              'redirect_source'     => nil,
              'maintenance_page'    => false,
              'deployment_page'     => false
            ) }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }
            it { is_expected.to contain_firewall('300 accept HTTP traffic') }

            it { is_expected.to contain_class('profiles::nodejs') }
            it { is_expected.to contain_class('profiles::apache') }

            it { is_expected.to contain_file('/var/www/uit-frontend').with(
              'ensure' => 'directory',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.not_to contain_file('uit-frontend-redirects') }
            it { is_expected.not_to contain_file('uit-frontend-migration-script') }
            it { is_expected.not_to contain_file('uit-maintenance-page') }
            it { is_expected.not_to contain_file('uit-deployment-page') }

            it { is_expected.to contain_class('profiles::uit::frontend::deployment').with(
              'service_address' => '127.0.0.1',
              'service_port'    => 3000
            ) }

            it { is_expected.to contain_class('profiles::uit::frontend::logging').with(
              'servername' => 'foo.example.com'
            ) }

            it { is_expected.to contain_apache__vhost('foo.example.com_80').with(
              'servername'         => 'foo.example.com',
              'serveraliases'      => [],
              'docroot'            => '/var/www/uit-frontend',
              'manage_docroot'     => false,
              'port'               => 80,
              'access_log_format'  => 'extended_json',
              'access_log_env_var' => '!nolog',
              'custom_fragment'    => nil,
              'error_documents'    => [],
              'request_headers'    => [
                                        'unset Proxy early',
                                        'set X-Unique-Id %{UNIQUE_ID}e'
                                      ],
              'directories'        => [{
                                        'path'           => '/',
                                        'options'        => ['Indexes', 'MultiViews'],
                                        'allow_override' => ['All'],
                                        'require'        => { 'enforce' => 'all', 'requires' => ['all granted'] }
                                      },
                                      {
                                        'path'           => '/(css/|img/|js/|icons/|_nuxt/|sw.js)',
                                        'provider'       => 'locationmatch',
                                        'headers'        => [
                                                              'set Cache-Control "max-age=31536000, public"',
                                                              'unset Last-Modified "expr=%{REQUEST_URI} =~ m#^/_nuxt/#"'
                                                            ]
                                      }],
              'aliases'            => [{
                                        'aliasmatch' => '^/(css/|img/|js/|icons/|_nuxt/|sw.js)(.*)$',
                                        'path'       => '/var/www/uit-frontend/packages/app/.output/public/$1$2'
                                      }],
              'proxy_pass'         => [{
                                        'path'                => '/',
                                        'url'                 => 'http://127.0.0.1:3000/',
                                        'no_proxy_uris'       => [],
                                        'no_proxy_uris_match' => ['^/(css/|img/|js/|icons/|_nuxt/|sw.js)']
                                      }],
              'rewrites'           => [{
                                        'comment'      => 'Serve brotli compressed assets for supported clients',
                                        'rewrite_cond' => [
                                                            '%{HTTP:Accept-encoding} "br"',
                                                            '/var/www/uit-frontend/packages/app/.output/public%{REQUEST_FILENAME}.br -f'
                                                          ],
                                        'rewrite_rule' => '^/(css/|img/|js/|icons/|_nuxt/)(.*)$ /var/www/uit-frontend/packages/app/.output/public/$1$2.br [E=brotli]'
                                      }, {
                                        'comment'      => 'Serve gzip compressed assets for supported clients',
                                        'rewrite_cond' => [
                                                            '%{HTTP:Accept-encoding} "gzip"',
                                                            '/var/www/uit-frontend/packages/app/.output/public%{REQUEST_FILENAME}.gz -f'
                                                          ],
                                        'rewrite_rule' => '^/(css/|img/|js/|icons/|_nuxt/)(.*)$ /var/www/uit-frontend/packages/app/.output/public/$1$2.gz [E=gzip]'
                                      }, {
                                        'comment'      => 'Do not compress pre-compressed content in transfer',
                                        'rewrite_rule' => [
                                                            '\.css\.(gz|br)$ - [T=text/css,E=no-gzip:1,E=no-brotli:1]',
                                                            '\.js\.(gz|br)$ - [T=text/javascript,E=no-gzip:1,E=no-brotli:1]',
                                                            '\.svg\.(gz|br)$ - [T=image/svg+xml,E=no-gzip:1,E=no-brotli:1]'
                                                          ]
                                      }],
              'headers'            => [
                                        'append Content-Encoding "br" "env=brotli"',
                                        'append Content-Encoding "gzip" "env=gzip"',
                                        'append Vary "Accept-Encoding" "env=brotli"',
                                        'append Vary "Accept-Encoding" "env=gzip"'
                                      ],
              'setenvif'           => [
                                        'X-Forwarded-Proto "https" HTTPS=on',
                                        'X-Forwarded-For "^([^,]*),?.*" CLIENT_IP=$1'
                                      ]
            ) }

            it { is_expected.to contain_file('/var/www/uit-frontend').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('/var/www/uit-frontend').that_requires('User[www-data]') }
            it { is_expected.to contain_class('profiles::uit::frontend::deployment').that_requires('Class[profiles::nodejs]') }
            it { is_expected.to contain_apache__vhost('foo.example.com_80').that_requires('Class[profiles::uit::frontend::deployment]') }
            it { is_expected.to contain_apache__vhost('foo.example.com_80').that_requires('Class[profiles::apache]') }
            it { is_expected.to contain_apache__vhost('foo.example.com_80').that_requires('File[/var/www/uit-frontend]') }
          end

          context "without hieradata" do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
          end
        end

        context "with service_address => 127.0.1.1, service_port => 7000, redirect_source => /tmp/foo, maintenance_page => true and deployment_page => true" do
          let(:params) {
            super().merge( {
              'service_address'  => '127.0.1.1',
              'service_port'     => 7000,
              'redirect_source'  => '/tmp/foo',
              'maintenance_page' => true,
              'deployment_page'  => true
            } )
          }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uit::frontend::deployment').with(
              'service_address' => '127.0.1.1',
              'service_port'    => 7000
            ) }

            it { is_expected.to contain_file('uit-frontend-migration-script').with(
              'ensure'  => 'file',
              'path'    => '/var/www/uit-frontend/migrate.sh',
              'owner'   => 'www-data',
              'group'   => 'www-data',
              'mode'    => '0755'
            ) }

            it { is_expected.to contain_file('uit-frontend-redirects').with(
              'ensure'  => 'file',
              'path'    => '/var/www/uit-frontend/.redirect',
              'owner'   => 'www-data',
              'group'   => 'www-data',
              'source'  => '/tmp/foo'
            ) }

            it { is_expected.to contain_file('uit-maintenance-page').with(
              'ensure'  => 'directory',
              'path'    => '/var/www/uit-frontend/maintenance/',
              'recurse' => true,
              'purge'   => true,
              'source'  => 'puppet:///modules/profiles/uit/frontend/maintenance',
              'owner'   => 'www-data',
              'group'   => 'www-data'
            ) }

            it { is_expected.to contain_file('uit-deployment-page').with(
              'ensure'  => 'directory',
              'path'    => '/var/www/uit-frontend/deployment/',
              'recurse' => true,
              'purge'   => true,
              'source'  => 'puppet:///modules/profiles/uit/frontend/deployment',
              'owner'   => 'www-data',
              'group'   => 'www-data'
            ) }

            it { is_expected.to contain_apache__vhost('foo.example.com_80').with(
              'custom_fragment'    => 'Include /var/www/uit-frontend/.redirect',
              'error_documents'    => [{
                                        'error_code' => 503,
                                        'document'   => '/maintenance/index.html'
                                      }, {
                                        'error_code' => 504,
                                        'document'   => '/deployment/index.html'
                                      }],
              'proxy_pass'         => [{
                                        'path'                => '/',
                                        'url'                 => 'http://127.0.1.1:7000/',
                                        'no_proxy_uris'       => ['/maintenance/', '/deployment/'],
                                        'no_proxy_uris_match' => ['^/(css/|img/|js/|icons/|_nuxt/|sw.js)']
                                      }],
              'rewrites'           => [{
                                        'comment'      => 'Maintenance page',
                                        'rewrite_cond' => [
                                                            '%{DOCUMENT_ROOT}/maintenance/index.html -f',
                                                            '%{DOCUMENT_ROOT}/maintenance.enabled -f',
                                                            '%{REQUEST_URI} !^/maintenance/'
                                                          ],
                                        'rewrite_rule' => '^ - [R=503,L]'
                                      }, {
                                        'comment'      => 'Deployment in progress page',
                                        'rewrite_cond' => [
                                                            '%{DOCUMENT_ROOT}/deployment/index.html -f',
                                                            '%{DOCUMENT_ROOT}/api.deployment.enabled -f [OR]',
                                                            '%{DOCUMENT_ROOT}/frontend.deployment.enabled -f [OR]',
                                                            '%{DOCUMENT_ROOT}/cms.deployment.enabled -f [OR]',
                                                            '%{DOCUMENT_ROOT}/deployment.enabled -f',
                                                            '%{REQUEST_URI} !^/deployment/'
                                                          ],
                                        'rewrite_rule' => '^ - [R=504,L]'
                                      }, {
                                        'comment'      => 'Serve brotli compressed assets for supported clients',
                                        'rewrite_cond' => [
                                                            '%{HTTP:Accept-encoding} "br"',
                                                            '/var/www/uit-frontend/packages/app/.output/public%{REQUEST_FILENAME}.br -f'
                                                          ],
                                        'rewrite_rule' => '^/(css/|img/|js/|icons/|_nuxt/)(.*)$ /var/www/uit-frontend/packages/app/.output/public/$1$2.br [E=brotli]'
                                      }, {
                                        'comment'      => 'Serve gzip compressed assets for supported clients',
                                        'rewrite_cond' => [
                                                            '%{HTTP:Accept-encoding} "gzip"',
                                                            '/var/www/uit-frontend/packages/app/.output/public%{REQUEST_FILENAME}.gz -f'
                                                          ],
                                        'rewrite_rule' => '^/(css/|img/|js/|icons/|_nuxt/)(.*)$ /var/www/uit-frontend/packages/app/.output/public/$1$2.gz [E=gzip]'
                                      }, {
                                        'comment'      => 'Do not compress pre-compressed content in transfer',
                                        'rewrite_rule' => [
                                                            '\.css\.(gz|br)$ - [T=text/css,E=no-gzip:1,E=no-brotli:1]',
                                                            '\.js\.(gz|br)$ - [T=text/javascript,E=no-gzip:1,E=no-brotli:1]',
                                                            '\.svg\.(gz|br)$ - [T=image/svg+xml,E=no-gzip:1,E=no-brotli:1]'
                                                          ]
                                      }]
            ) }

            it { is_expected.to contain_file('uit-frontend-migration-script').that_requires('File[/var/www/uit-frontend]') }
            it { is_expected.to contain_file('uit-frontend-migration-script').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('uit-frontend-migration-script').that_requires('User[www-data]') }
            it { is_expected.to contain_file('uit-frontend-migration-script').that_notifies('Class[apache::service]') }
            it { is_expected.to contain_file('uit-frontend-redirects').that_requires('File[/var/www/uit-frontend]') }
            it { is_expected.to contain_file('uit-frontend-redirects').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('uit-frontend-redirects').that_requires('User[www-data]') }
            it { is_expected.to contain_file('uit-frontend-redirects').that_notifies('Class[apache::service]') }
            it { is_expected.to contain_file('uit-maintenance-page').that_requires('File[/var/www/uit-frontend]') }
            it { is_expected.to contain_file('uit-maintenance-page').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('uit-maintenance-page').that_requires('User[www-data]') }
            it { is_expected.to contain_file('uit-deployment-page').that_requires('File[/var/www/uit-frontend]') }
            it { is_expected.to contain_file('uit-deployment-page').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('uit-deployment-page').that_requires('User[www-data]') }
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
          it { is_expected.to_not contain_class('profiles::uit::frontend::deployment') }
        end
      end
    end
  end

  context "with servername => bar.example.com" do
    let(:params) { {
      'servername' => 'bar.example.com'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_apache__vhost('bar.example.com_80').with(
            'servername' => 'bar.example.com'
          ) }

          it { is_expected.to contain_class('profiles::uit::frontend::logging').with(
            'servername' => 'bar.example.com'
          ) }

          it { is_expected.to contain_apache__vhost('bar.example.com_80').that_requires('Class[profiles::uit::frontend::deployment]') }
          it { is_expected.to contain_apache__vhost('bar.example.com_80').that_requires('Class[profiles::apache]') }
          it { is_expected.to contain_apache__vhost('bar.example.com_80').that_requires('File[/var/www/uit-frontend]') }
        end
      end
    end
  end

  context "without parameters" do
    let(:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
