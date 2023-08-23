require 'spec_helper'

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
              'servername'              => 'foo.example.com',
              'serveraliases'           => [],
              'deployment'              => true,
              'service_address'         => '127.0.0.1',
              'service_port'            => 3000,
              'redirect_source'         => nil,
              'uitdatabank_api_url'     => nil,
              'maintenance_page_source' => nil,
              'deployment_page_source'  => nil
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

            it { is_expected.to contain_apache__vhost('foo.example.com_80').with(
              'servername'         => 'foo.example.com',
              'serveraliases'      => [],
              'docroot'            => '/var/www/uit-frontend',
              'manage_docroot'     => false,
              'port'               => 80,
              'access_log_env_var' => '!nolog',
              'custom_fragment'    => nil,
              'error_documents'    => [],
              'request_headers'    => ['unset Proxy early'],
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
                                                            '/var/www/uit-frontend/packages/app/.output/public%{REQUEST_FILENAME}\.br -f'
                                                          ],
                                        'rewrite_rule' => '^/(css/|img/|js/|icons/|_nuxt/)(.*)$ /var/www/uit-frontend/packages/app/.output/public/$1$2.br [E=brotli,L]'
                                      }, {
                                        'comment'      => 'Do not compress pre-compressed brotli content in transfer',
                                        'rewrite_rule' => [
                                                            '\.css\.br$ - [T=text/css,E=no-gzip:1,E=no-brotli:1]',
                                                            '\.js\.br$ - [T=text/javascript,E=no-gzip:1,E=no-brotli:1]',
                                                            '\.svg\.br$ - [T=image/svg+xml,E=no-gzip:1,E=no-brotli:1]'
                                                          ]
                                      }],
              'headers'            => [
                                        'append Content-Encoding "br" "env=brotli"',
                                        'append Vary "Accept-Encoding" "env=brotli"'
                                      ],
              'setenvif'           => [
                                        'X-Forwarded-Proto "https" HTTPS=on',
                                        'X-Forwarded-For "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+).*" CLIENT_IP=$1'
                                      ]
            ) }

            it { is_expected.to contain_file('/var/www/uit-frontend').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('/var/www/uit-frontend').that_requires('User[www-data]') }
            it { is_expected.to contain_file('/var/www/uit-frontend').that_requires('Class[profiles::apache]') }
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
