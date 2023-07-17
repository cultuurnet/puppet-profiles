require 'spec_helper'

describe 'profiles::uitdatabank::rdf' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with servername => rdf.example.com" do
        let(:params) { {
          'servername' => 'rdf.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::rdf').with(
          'servername' => 'rdf.example.com',
          'sparql_url' => 'http://127.0.0.1:8080/'
        ) }

        it { is_expected.to contain_firewall('300 accept HTTP traffic') }
        it { is_expected.to contain_class('profiles::apache') }

        it { is_expected.to contain_apache__vhost('rdf.example.com_80').with(
          'servername'        => 'rdf.example.com',
          'docroot'           => '/var/www/html',
          'manage_docroot'    => false,
          'port'              => 80,
          'ssl'               => false,
          'access_log_format' => 'combined_json',
          'request_headers'   => [
                                   'unset Proxy early',
                                   'set X-Unique-Id %{UNIQUE_ID}e',
                                   'setifempty X-Forwarded-Port "80"',
                                   'setifempty X-Forwarded-Proto "http"'
                                 ],
          'rewrites'          => [ {
                                   'comment'      => 'Reverse proxy /(events|places|organizers)/<uuid> to Jena Fuseki backend with ?graph= query string',
                                   'rewrite_cond' => [
                                                       '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                                       '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                                   ],
                                   'rewrite_rule' => '^/(events|places|organizers)/(.*)$ http://127.0.0.1:8080/$1/?graph=https://%{HTTP_HOST}/$1/$2.ttl [P]'
                                 } ],
          'proxy_pass'        => {
                                   'path'         => '/',
                                   'url'          => 'http://127.0.0.1:8080/',
                                   'keywords'     => [],
                                   'reverse_urls' => 'http://127.0.0.1:8080/',
                                   'params'       => {}
                                 }
        ) }
      end

      context "with servername => foo.example.com and sparql_url => http://127.0.1.1:18080/" do
        let(:params) { {
          'servername' => 'foo.example.com',
          'sparql_url' => 'http://127.0.1.1:18080/'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apache__vhost('foo.example.com_80').with(
          'servername'        => 'foo.example.com',
          'docroot'           => '/var/www/html',
          'manage_docroot'    => false,
          'port'              => 80,
          'ssl'               => false,
          'access_log_format' => 'combined_json',
          'request_headers'   => [
                                   'unset Proxy early',
                                   'set X-Unique-Id %{UNIQUE_ID}e',
                                   'setifempty X-Forwarded-Port "80"',
                                   'setifempty X-Forwarded-Proto "http"'
                                 ],
          'rewrites'          => [ {
                                   'comment'      => 'Reverse proxy /(events|places|organizers)/<uuid> to Jena Fuseki backend with ?graph= query string',
                                   'rewrite_cond' => [
                                                     '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                                     '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                                   ],
                                   'rewrite_rule' => '^/(events|places|organizers)/(.*)$ http://127.0.1.1:18080/$1/?graph=https://%{HTTP_HOST}/$1/$2.ttl [P]'
                                 } ],
          'proxy_pass'        => {
                                   'path'         => '/',
                                   'url'          => 'http://127.0.1.1:18080/',
                                   'keywords'     => [],
                                   'reverse_urls' => 'http://127.0.1.1:18080/',
                                   'params'       => {}
                                 }
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
