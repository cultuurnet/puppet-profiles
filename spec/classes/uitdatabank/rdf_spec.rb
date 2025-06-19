describe 'profiles::uitdatabank::rdf' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context "with servername => rdf.example.com" do
          let(:params) { {
            'servername' => 'rdf.example.com'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::rdf').with(
            'servername'    => 'rdf.example.com',
            'serveraliases' => [],
            'deployment'    => true
          ) }

          it { is_expected.to contain_class('profiles::apache') }
          it { is_expected.to contain_class('profiles::redis') }
          it { is_expected.to contain_class('profiles::php') }

          it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://rdf.example.com').with(
              'basedir'               => '/var/www/udb3-backend',
              'public_web_directory'  => 'web',
              'aliases'               => [],
              'allow_encoded_slashes' => 'nodecode',
              'access_log_format'     => 'extended_json',
              'request_headers'       => [
                                           'set Accept "text/turtle"'
                                         ],
              'rewrites'              => [{
                                           'comment'      => 'Only allow GET requests',
                                           'rewrite_cond' => [
                                                               '%{REQUEST_METHOD} !GET'
                                                             ],
                                           'rewrite_rule' => '^ - [F,L]'
                                         }, {
                                           'comment'      => 'Only allow requests to /(event|place|organizer)s?/<uuid> or /id/(event|place|organizer)/udb/<uuid>',
                                           'rewrite_cond' => [
                                                               '%{REQUEST_URI} !^/(event|place|organizer)s?/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$',
                                                               '%{REQUEST_URI} !^/(event|place|organizer)s?/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$',
                                                               '%{REQUEST_URI} !^/id/(event|place|organizer)/udb/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$',
                                                               '%{REQUEST_URI} !^/id/(event|place|organizer)/udb/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$',
                                                               '%{REQUEST_URI} !^/index.php$'
                                                             ],
                                           'rewrite_rule' => '^ - [F,L]'
                                         }, {
                                           'comment'      => 'Reverse proxy /id/(event|place|organizer)/udb/<uuid> to backend',
                                           'rewrite_cond' => [
                                                               '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                                               '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                                             ],
                                           'rewrite_rule' => '^/id/(event|place|organizer)/udb/(.*)$ %{HTTP:X-Forwarded-Proto}://rdf.example.com/$1s/$2 [P]'
                                         }],
            'ssl_proxyengine'         => true
          ) }
        end

        context "with servername => foo.example.com, serveraliases => [bar.example.com, baz.example.com] and deployment => false" do
          let(:params) { {
            'servername'    => 'foo.example.com',
            'serveraliases' => ['bar.example.com', 'baz.example.com'],
            'deployment'    => false
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::deployment') }

          it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://foo.example.com').with(
              'basedir'               => '/var/www/udb3-backend',
              'public_web_directory'  => 'web',
              'aliases'               => ['bar.example.com', 'baz.example.com'],
              'allow_encoded_slashes' => 'nodecode',
              'access_log_format'     => 'extended_json',
              'request_headers'       => [
                                           'set Accept "text/turtle"'
                                         ],
              'rewrites'              => [{
                                           'comment'      => 'Only allow GET requests',
                                           'rewrite_cond' => [
                                                               '%{REQUEST_METHOD} !GET'
                                                             ],
                                           'rewrite_rule' => '^ - [F,L]'
                                         }, {
                                           'comment'      => 'Only allow requests to /(event|place|organizer)s?/<uuid> or /id/(event|place|organizer)/udb/<uuid>',
                                           'rewrite_cond' => [
                                                               '%{REQUEST_URI} !^/(event|place|organizer)s?/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$',
                                                               '%{REQUEST_URI} !^/(event|place|organizer)s?/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$',
                                                               '%{REQUEST_URI} !^/id/(event|place|organizer)/udb/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$',
                                                               '%{REQUEST_URI} !^/id/(event|place|organizer)/udb/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$',
                                                               '%{REQUEST_URI} !^/index.php$'
                                                             ],
                                           'rewrite_rule' => '^ - [F,L]'
                                         }, {
                                           'comment'      => 'Reverse proxy /id/(event|place|organizer)/udb/<uuid> to backend',
                                           'rewrite_cond' => [
                                                               '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                                               '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                                             ],
                                           'rewrite_rule' => '^/id/(event|place|organizer)/udb/(.*)$ %{HTTP:X-Forwarded-Proto}://foo.example.com/$1s/$2 [P]'
                                         }],
            'ssl_proxyengine'         => true
          ) }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
