describe 'profiles::uitdatabank::jwt_provider' do
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

          it { is_expected.to contain_class('profiles::uitdatabank::jwt_provider').with(
            'servername'    => 'baz.example.com',
            'serveraliases' => [],
            'deployment'    => true
          ) }

          it { is_expected.to contain_class('profiles::apache') }
          it { is_expected.to contain_class('profiles::php') }

          it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://baz.example.com').with(
            'basedir'              => '/var/www/jwt-provider',
            'public_web_directory' => 'web',
            'aliases'              => [],
            'access_log_format'    => 'apikey_json',
            'rewrites'             => [ {
                                          'comment'      => 'Capture apiKey from URL parameters',
                                          'rewrite_cond' => '%{QUERY_STRING} (?:^|&)apiKey=([^&]+)',
                                          'rewrite_rule' => '^ - [E=API_KEY:%1]'
                                        }, {
                                          'comment'      => 'Capture apiKey from X-Api-Key header',
                                          'rewrite_cond' => '%{HTTP:X-Api-Key} ^.+',
                                          'rewrite_rule' => '^ - [E=API_KEY:%{HTTP:X-Api-Key}]'
                                      } ]
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::jwt_provider::deployment') }

          it { is_expected.to contain_class('profiles::uitdatabank::jwt_provider::deployment').that_requires('Class[profiles::php]') }
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context 'with servername => jwt.example.com' do
        let(:params) { {
          'servername'    => 'jwt.example.com',
          'serveraliases' => ['jwt-alias1.example.com', 'jwt-alias2.example.com'],
          'deployment'    => false
        } }

        it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://jwt.example.com').with(
          'basedir'              => '/var/www/jwt-provider',
          'public_web_directory' => 'web',
          'aliases'              => ['jwt-alias1.example.com', 'jwt-alias2.example.com'],
          'access_log_format'    => 'apikey_json',
          'rewrites'             => [ {
                                        'comment'      => 'Capture apiKey from URL parameters',
                                        'rewrite_cond' => '%{QUERY_STRING} (?:^|&)apiKey=([^&]+)',
                                        'rewrite_rule' => '^ - [E=API_KEY:%1]'
                                      }, {
                                        'comment'      => 'Capture apiKey from X-Api-Key header',
                                        'rewrite_cond' => '%{HTTP:X-Api-Key} ^.+',
                                        'rewrite_rule' => '^ - [E=API_KEY:%{HTTP:X-Api-Key}]'
                                    } ]
        ) }

        it { is_expected.not_to contain_class('profiles::uitdatabank::jwt_provider::deployment') }
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
