require 'spec_helper'

describe 'profiles::apache::vhost::php_fpm' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with title => http://winston.example.com" do
        let(:title) { 'http://winston.example.com' }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          context "with basedir => /var/www/foo" do
            let(:params) { {
              'basedir' => '/var/www/foo'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://winston.example.com').with(
              'basedir'              => '/var/www/foo',
              'public_web_directory' => 'public',
              'aliases'              => [],
              'socket_type'          => 'unix',
              'certificate'          => nil
            ) }

            it { is_expected.to contain_firewall('300 accept HTTP traffic') }

            it { is_expected.to contain_class('apache::mod::proxy') }
            it { is_expected.to contain_class('apache::mod::proxy_fcgi') }
            it { is_expected.to contain_class('apache::mod::rewrite') }

            it { is_expected.to contain_apache__vhost('winston.example.com_80').with(
              'servername'      => 'winston.example.com',
              'serveraliases'   => [],
              'docroot'         => '/var/www/foo/public',
              'manage_docroot'  => false,
              'port'            => 80,
              'ssl'             => false,
              'request_headers' => [
                                     'unset Proxy early',
                                     'setifempty X-Forwarded-Port "80"',
                                     'setifempty X-Forwarded-Proto "http"'
                                   ],
              'directories'     => [
                                     {
                                       'path'            => '\.php$',
                                       'provider'        => 'filesmatch',
                                       'custom_fragment' => 'SetHandler "proxy:unix:/var/run/php/php-fpm.sock|fcgi://localhost"'
                                     },
                                     {
                                       'path'           => '/var/www/foo',
                                       'options'        => ['Indexes', 'FollowSymLinks', 'MultiViews'],
                                       'allow_override' => 'All'
                                     }
                                   ]
            ) }
          end

          context "with basedir => /tmp/bla, public_web_directory => web, aliases => [smith.example.com, foo.example.com] and socket_type => tcp" do
            let(:params) { {
              'basedir'              => '/tmp/bla',
              'public_web_directory' => 'web',
              'aliases'              => ['smith.example.com', 'foo.example.com'],
              'socket_type'          => 'tcp',
            } }

            it { is_expected.to contain_apache__vhost('winston.example.com_80').with(
              'servername'      => 'winston.example.com',
              'serveraliases'   => ['smith.example.com', 'foo.example.com'],
              'docroot'         => '/tmp/bla/web',
              'manage_docroot'  => false,
              'port'            => 80,
              'ssl'             => false,
              'request_headers' => [
                                     'unset Proxy early',
                                     'setifempty X-Forwarded-Port "80"',
                                     'setifempty X-Forwarded-Proto "http"'
                                   ],
              'directories'     => [
                                     {
                                       'path'            => '\.php$',
                                       'provider'        => 'filesmatch',
                                       'custom_fragment' => 'SetHandler "proxy:fcgi://127.0.0.1:9000"'
                                     },
                                     {
                                       'path'           => '/tmp/bla',
                                       'options'        => ['Indexes', 'FollowSymLinks', 'MultiViews'],
                                       'allow_override' => 'All'
                                     }
                                   ]
            ) }
          end
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with basedir => /var/www/bar" do
            let(:params) { {
              'basedir' => '/var/www/bar'
            } }

            it { is_expected.to contain_apache__vhost('winston.example.com_80').with(
              'servername'      => 'winston.example.com',
              'serveraliases'   => [],
              'docroot'         => '/var/www/bar/public',
              'manage_docroot'  => false,
              'port'            => 80,
              'ssl'             => false,
              'request_headers' => [
                                     'unset Proxy early',
                                     'setifempty X-Forwarded-Port "80"',
                                     'setifempty X-Forwarded-Proto "http"'
                                   ],
              'directories'     => [
                                     {
                                       'path'            => '\.php$',
                                       'provider'        => 'filesmatch',
                                       'custom_fragment' => 'SetHandler "proxy:fcgi://127.0.0.1:9000"'
                                     },
                                     {
                                       'path'           => '/var/www/bar',
                                       'options'        => ['Indexes', 'FollowSymLinks', 'MultiViews'],
                                       'allow_override' => 'All'
                                     }
                                   ]
            ) }
          end
        end
      end

      context "with title => https://goldstein.example.com" do
        let(:title) { 'https://goldstein.example.com' }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with basedir => /data/web" do
            let(:params) { {
              'basedir' => '/data/web'
            } }

            it { expect { catalogue }.to raise_error(Puppet::Error, /expects a value for parameter certificate when using HTTPS/) }
          end

          context "with basedir => /data/web and certificate => wildcard.example.com" do
            let(:params) { {
              'basedir'     => '/data/web',
              'certificate' => 'wildcard.example.com'
            } }

            it { is_expected.to contain_firewall('300 accept HTTPS traffic') }

            it { is_expected.to contain_profiles__certificate('wildcard.example.com') }

            it { is_expected.to contain_apache__vhost('goldstein.example.com_443').with(
              'servername'      => 'goldstein.example.com',
              'serveraliases'   => [],
              'docroot'         => '/data/web/public',
              'manage_docroot'  => false,
              'port'            => 443,
              'ssl'             => true,
              'ssl_cert'        => '/etc/ssl/certs/wildcard.example.com.bundle.crt',
              'ssl_key'         => '/etc/ssl/private/wildcard.example.com.key',
              'request_headers' => [
                                     'unset Proxy early',
                                     'setifempty X-Forwarded-Port "443"',
                                     'setifempty X-Forwarded-Proto "https"'
                                   ],
              'directories'     => [
                                     {
                                       'path'            => '\.php$',
                                       'provider'        => 'filesmatch',
                                       'custom_fragment' => 'SetHandler "proxy:fcgi://127.0.0.1:9000"'
                                     },
                                     {
                                       'path'           => '/data/web',
                                       'options'        => ['Indexes', 'FollowSymLinks', 'MultiViews'],
                                       'allow_override' => 'All'
                                     }
                                   ]
            ) }
          end
        end
      end


      context "with title => http://julia.example.com" do
        let(:title) { 'http://julia.example.com' }

        context "with basedir => /var/www/html" do
          let(:params) { {
            'basedir' => '/var/www/html'
          } }

          it { is_expected.to contain_apache__vhost('julia.example.com_80').with(
            'servername'      => 'julia.example.com',
            'serveraliases'   => [],
            'docroot'         => '/var/www/html/public',
            'manage_docroot'  => false,
            'port'            => 80,
            'ssl'             => false,
            'request_headers' => [
                                   'unset Proxy early',
                                   'setifempty X-Forwarded-Port "80"',
                                   'setifempty X-Forwarded-Proto "http"'
                                 ],
            'directories'     => [
                                   {
                                     'path'            => '\.php$',
                                     'provider'        => 'filesmatch',
                                     'custom_fragment' => 'SetHandler "proxy:unix:/var/run/php/php-fpm.sock|fcgi://localhost"'
                                   },
                                   {
                                     'path'           => '/var/www/html',
                                     'options'        => ['Indexes', 'FollowSymLinks', 'MultiViews'],
                                     'allow_override' => 'All'
                                   }
                                 ]
          ) }
        end

        context "without parameters" do
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'basedir'/) }
        end
      end
    end
  end
end
