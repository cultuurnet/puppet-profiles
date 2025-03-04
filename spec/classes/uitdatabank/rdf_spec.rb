describe 'profiles::uitdatabank::rdf' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with servername => rdf.example.com and backend_url => https://foo.example.com" do
        let(:params) { {
          'servername'  => 'rdf.example.com',
          'backend_url' => 'https://foo.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_firewall('300 accept HTTP traffic') }
        it { is_expected.to contain_class('profiles::apache') }

        it { is_expected.to contain_class('apache::mod::proxy') }
        it { is_expected.to contain_class('apache::mod::proxy_http') }
        it { is_expected.to contain_class('apache::mod::ssl') }

        it { is_expected.to contain_apache__vhost('rdf.example.com_80').with(
          'servername'        => 'rdf.example.com',
          'docroot'           => '/var/www/html',
          'manage_docroot'    => false,
          'port'              => 80,
          'ssl'               => false,
          'access_log_format' => 'extended_json',
          'ssl_proxyengine'   => true,
          'request_headers'   => [
                                   'unset Proxy early',
                                   'set X-Unique-Id %{UNIQUE_ID}e',
                                   'setifempty X-Forwarded-Port "80"',
                                   'setifempty X-Forwarded-Proto "http"',
                                   'set Accept "text/turtle"'
                                 ],
          'setenvif'          => [
                                   'X-Forwarded-Proto "https" HTTPS=on',
                                   'X-Forwarded-For "^([^,]*),?.*" CLIENT_IP=$1'
                                 ],
          'rewrites'          => [ {
                                   'comment'      => 'Reverse proxy /(events|places|organizers)/<uuid> to backend',
                                   'rewrite_cond' => [
                                                       '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                                       '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                                     ],
                                   'rewrite_rule' => '^/(events|places|organizers)/(.*)$ https://foo.example.com/$1/$2 [P]'
                                 }, {
                                   'comment'      => 'Reverse proxy /id/(event|place|organizer)/udb/<uuid> to backend',
                                   'rewrite_cond' => [
                                                       '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                                       '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                                     ],
                                   'rewrite_rule' => '^/id/(event|place|organizer)/udb/(.*)$ https://foo.example.com/$1s/$2 [P]'
                                 } ]
        ) }

        it { is_expected.to contain_class('apache::mod::proxy').that_comes_before('Apache::Vhost[rdf.example.com_80]') }
        it { is_expected.to contain_class('apache::mod::proxy_http').that_comes_before('Apache::Vhost[rdf.example.com_80]') }
        it { is_expected.to contain_class('apache::mod::ssl').that_comes_before('Apache::Vhost[rdf.example.com_80]') }
      end

      context "with servername => foo.example.com and backend_url => http://bar.example.com/" do
        let(:params) { {
          'servername'  => 'foo.example.com',
          'backend_url' => 'http://bar.example.com/'
        } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_class('apache::mod::ssl') }

        it { is_expected.to contain_apache__vhost('foo.example.com_80').with(
          'servername'        => 'foo.example.com',
          'docroot'           => '/var/www/html',
          'manage_docroot'    => false,
          'port'              => 80,
          'ssl'               => false,
          'access_log_format' => 'extended_json',
          'ssl_proxyengine'   => false,
          'request_headers'   => [
                                   'unset Proxy early',
                                   'set X-Unique-Id %{UNIQUE_ID}e',
                                   'setifempty X-Forwarded-Port "80"',
                                   'setifempty X-Forwarded-Proto "http"',
                                   'set Accept "text/turtle"'
                                 ],
          'setenvif'          => [
                                   'X-Forwarded-Proto "https" HTTPS=on',
                                   'X-Forwarded-For "^([^,]*),?.*" CLIENT_IP=$1'
                                 ],
          'rewrites'          => [ {
                                   'comment'      => 'Reverse proxy /(events|places|organizers)/<uuid> to backend',
                                   'rewrite_cond' => [
                                                     '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                                     '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                                   ],
                                   'rewrite_rule' => '^/(events|places|organizers)/(.*)$ http://bar.example.com/$1/$2 [P]'
                                 }, {
                                   'comment'      => 'Reverse proxy /id/(event|place|organizer)/udb/<uuid> to backend',
                                   'rewrite_cond' => [
                                                     '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                                     '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                                   ],
                                   'rewrite_rule' => '^/id/(event|place|organizer)/udb/(.*)$ http://bar.example.com/$1s/$2 [P]'
                                 } ]
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'backend_url'/) }
      end
    end
  end
end
