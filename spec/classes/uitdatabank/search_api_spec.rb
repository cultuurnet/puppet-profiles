describe 'profiles::uitdatabank::search_api' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with servername => baz.example.com' do
        let(:params) { {
          'servername' => 'baz.example.com'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api').with(
            'servername'               => 'baz.example.com',
            'serveraliases'            => [],
            'elasticsearch_servername' => nil,
            'deployment'               => true,
            'data_migration'           => false
          ) }

          it { is_expected.to contain_class('profiles::elasticsearch') }
          it { is_expected.to contain_class('profiles::apache') }
          it { is_expected.to contain_class('profiles::php') }

          it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://baz.example.com').with(
            'basedir'              => '/var/www/udb3-search-service',
            'public_web_directory' => 'web',
            'aliases'              => [],
            'access_log_format'    => 'apikey_json',
            'rewrites'             => [ {
                                          'comment'      => 'Capture apiKey from URL parameters',
                                          'rewrite_cond' => '%{QUERY_STRING} (?:^|&)apiKey=([^&]+)',
                                          'rewrite_rule' => '^ - [E=APIKEY:%1]'
                                        }, {
                                          'comment'      => 'Capture apiKey from X-Api-Key header',
                                          'rewrite_cond' => '%{HTTP:X-Api-Key} ^.+',
                                          'rewrite_rule' => '^ - [E=APIKEY:%{HTTP:X-Api-Key}]'
                                      } ]
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::geojson_data::deployment') }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment') }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::logging').with(
            'servername' => 'baz.example.com'
          ) }

          it { is_expected.not_to contain_class('profiles::uitdatabank::search_api::data_migration') }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment').that_requires('Class[profiles::uitdatabank::geojson_data::deployment]') }
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'features_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'facilities_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'themes_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'types_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'pubkey_auth0_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'pubkey_keycloak_source'/) }
        end
      end

      context "with servername => foo.example.com, serveraliases => [alias1.example.com, alias2.example.com], elasticsearch_servername => es.example.com and data_migration => true" do
        let(:params) { {
          'servername'               => 'foo.example.com',
          'serveraliases'            => ['alias1.example.com', 'alias2.example.com'],
          'elasticsearch_servername' => 'es.example.com',
          'data_migration'           => true
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://foo.example.com').with(
            'basedir'              => '/var/www/udb3-search-service',
            'public_web_directory' => 'web',
            'aliases'              => ['alias1.example.com', 'alias2.example.com'],
            'access_log_format'    => 'apikey_json',
            'rewrites'             => [ {
                                          'comment'      => 'Capture apiKey from URL parameters',
                                          'rewrite_cond' => '%{QUERY_STRING} (?:^|&)apiKey=([^&]+)',
                                          'rewrite_rule' => '^ - [E=APIKEY:%1]'
                                        }, {
                                          'comment'      => 'Capture apiKey from X-Api-Key header',
                                          'rewrite_cond' => '%{HTTP:X-Api-Key} ^.+',
                                          'rewrite_rule' => '^ - [E=APIKEY:%{HTTP:X-Api-Key}]'
                                      } ]
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://es.example.com').with(
            'destination' => 'http://127.0.0.1:9200/'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::logging').with(
            'servername' => 'foo.example.com'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::data_migration') }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::data_migration').that_subscribes_to('Class[profiles::uitdatabank::search_api::deployment]') }
          it { is_expected.to contain_class('profiles::uitdatabank::search_api::data_migration').that_subscribes_to('Class[profiles::uitdatabank::geojson_data::deployment]') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
