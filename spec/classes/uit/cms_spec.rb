describe 'profiles::uit::cms' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with servername => baz.example.com, frontend_url => https://www.example.com and database_password => secret' do
        let(:params) { {
          'servername'        => 'baz.example.com',
          'frontend_url'      => 'https://www.example.com',
          'database_password' => 'secret'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uit::cms').with(
            'servername'        => 'baz.example.com',
            'frontend_url'      => 'https://www.example.com',
            'database_password' => 'secret',
            'serveraliases'     => [],
            'deployment'        => true,
            'lvm'               => false,
            'volume_group'      => nil,
            'volume_size'       => nil
          ) }

          it { is_expected.to contain_class('profiles::redis') }
          it { is_expected.to contain_class('profiles::php') }
          it { is_expected.to contain_class('profiles::apache') }
          it { is_expected.to contain_class('profiles::mysql::server') }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_file('/var/www/uit-cms').with(
            'ensure' => 'directory',
            'owner'  => 'www-data',
            'group'  => 'www-data',
          ) }

          it { is_expected.to contain_file('/var/www/uit-cms/web').with(
            'ensure' => 'directory',
            'owner'  => 'www-data',
            'group'  => 'www-data',
          ) }

          it { is_expected.to contain_file('/var/www/uit-cms/web/sites').with(
            'ensure' => 'directory',
            'owner'  => 'www-data',
            'group'  => 'www-data',
          ) }

          it { is_expected.to contain_file('/var/www/uit-cms/web/sites/default').with(
            'ensure' => 'directory',
            'owner'  => 'www-data',
            'group'  => 'www-data',
          ) }

          it { is_expected.to contain_file('/var/www/uit-cms/web/sites/default/files').with(
            'ensure' => 'directory',
            'owner'  => 'www-data',
            'group'  => 'www-data',
          ) }

          it { is_expected.to contain_file('hostnames.txt').with(
            'ensure' => 'file',
            'path'   => '/var/www/uit-cms/hostnames.txt',
            'owner'  => 'www-data',
            'group'  => 'www-data',
          ) }

          it { is_expected.to contain_file('hostnames.txt').with_content(/^baz\.example\.com https:\/\/www\.example\.com$/) }

          it { is_expected.to contain_class('profiles::mysql::server') }

          it { is_expected.to contain_mysql_database('uit_cms').with(
            'charset' => 'utf8mb4',
            'collate' => 'utf8mb4_unicode_ci'
          ) }

          it { is_expected.to contain_profiles__mysql__app_user('uit_cms@uit_cms').with(
            'password' => 'secret'
          ) }

          it { is_expected.to contain_profiles__mysql__app_user('etl@uit_cms').with(
            'password' => 'my_etl_password',
            'remote'   => true,
            'readonly' => true
          ) }

          it { is_expected.to contain_class('profiles::uit::cms::deployment') }

          it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://baz.example.com').with(
            'basedir'              => '/var/www/uit-cms',
            'public_web_directory' => 'web',
            'aliases'              => [],
            'rewrites'             => [ {
                                          'comment'      => 'Redirect all requests to /tip/ to the frontend vhost',
                                          'rewrite_map'  => "hostnames 'txt:/var/www/uit-cms/hostnames.txt'",
                                          'rewrite_rule' => '^/tip/(.*)$ ${hostnames:%{HTTP_HOST}}/tip/$1 [R=301,NE,L]'
                                      } ]
          ) }

          it { is_expected.to contain_file('/var/www/uit-cms').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/var/www/uit-cms').that_requires('User[www-data]') }
          it { is_expected.to contain_file('/var/www/uit-cms/web').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/var/www/uit-cms/web').that_requires('User[www-data]') }
          it { is_expected.to contain_file('/var/www/uit-cms/web/sites').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/var/www/uit-cms/web/sites').that_requires('User[www-data]') }
          it { is_expected.to contain_file('/var/www/uit-cms/web/sites/default').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/var/www/uit-cms/web/sites/default').that_requires('User[www-data]') }
          it { is_expected.to contain_file('/var/www/uit-cms/web/sites/default/files').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/var/www/uit-cms/web/sites/default/files').that_requires('User[www-data]') }
          it { is_expected.to contain_file('hostnames.txt').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('hostnames.txt').that_requires('User[www-data]') }
          it { is_expected.to contain_file('hostnames.txt').that_comes_before('Profiles::Apache::Vhost::Php_fpm[http://baz.example.com]') }
          it { is_expected.to contain_mysql_database('uit_cms').that_requires('Class[profiles::mysql::server]') }
          it { is_expected.to contain_profiles__mysql__app_user('uit_cms@uit_cms').that_requires('Mysql_database[uit_cms]') }
          it { is_expected.to contain_profiles__mysql__app_user('etl@uit_cms').that_requires('Mysql_database[uit_cms]') }
          it { is_expected.to contain_class('profiles::uit::cms::deployment').that_requires('Class[profiles::redis]') }
          it { is_expected.to contain_class('profiles::uit::cms::deployment').that_requires('Class[profiles::php]') }
          it { is_expected.to contain_class('profiles::uit::cms::deployment').that_requires('Class[profiles::mysql::server]') }
          it { is_expected.to contain_class('profiles::uit::cms::deployment').that_requires('Mysql_database[uit_cms]') }
          it { is_expected.to contain_class('profiles::uit::cms::deployment').that_requires('Profiles::Mysql::App_user[uit_cms]') }
          it { is_expected.to contain_class('profiles::uit::cms::deployment').that_requires('File[/var/www/uit-cms/web/sites/default/files]') }
        end

        context 'with deployment => false' do
          let(:params) {
            super().merge( { 'deployment' => false } )
          }

          context 'with hieradata' do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to_not contain_class('profiles::uit::cms::deployment') }
          end

          context 'without hieradata' do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /parameter 'password' expects a String value, got Undef/) }
          end
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context 'with servername => tic.example.com, frontend_url => https://game.example.com, serveraliases => [tac.example.com, toe.example.com], database_password => notsosecret, lvm => true, volume_group => myvg and volume_size = 10G' do
        let(:params) { {
          'servername'        => 'tic.example.com',
          'serveraliases'     => ['tac.example.com', 'toe.example.com'],
          'frontend_url'      => 'https://game.example.com',
          'database_password' => 'notsosecret',
          'lvm'               => true,
          'volume_group'      => 'myvg',
          'volume_size'       => '10G'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with volume_group myvg present" do
            let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

            it { is_expected.to contain_file('hostnames.txt').with_content(/^tic\.example\.com https:\/\/game\.example\.com$/) }

            it { is_expected.to contain_profiles__mysql__app_user('uit_cms@uit_cms').with(
              'password' => 'notsosecret'
            ) }

            it { is_expected.to contain_profiles__lvm__mount('cmsdata').with(
              'volume_group' => 'myvg',
              'size'         => '10G',
              'mountpoint'   => '/data/cms',
              'fs_type'      => 'ext4',
              'owner'        => 'www-data',
              'group'        => 'www-data'
            ) }

            it { is_expected.to contain_mount('/var/www/uit-cms/web/sites/default/files').with(
              'ensure'  => 'mounted',
              'device'  => '/data/cms',
              'fstype'  => 'none',
              'options' => 'rw,bind'
            ) }

            it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://tic.example.com').with(
              'basedir'              => '/var/www/uit-cms',
              'public_web_directory' => 'web',
              'aliases'              => ['tac.example.com', 'toe.example.com'],
              'rewrites'             => [ {
                                            'comment'      => 'Redirect all requests to /tip/ to the frontend vhost',
                                            'rewrite_map'  => "hostnames 'txt:/var/www/uit-cms/hostnames.txt'",
                                            'rewrite_rule' => '^/tip/(.*)$ ${hostnames:%{HTTP_HOST}}/tip/$1 [R=301,NE,L]'
                                        } ]
            ) }

            it { is_expected.to contain_profiles__lvm__mount('cmsdata').that_comes_before('Mount[/var/www/uit-cms/web/sites/default/files]') }
            it { is_expected.to contain_class('profiles::uit::cms::deployment').that_requires('Mount[/var/www/uit-cms/web/sites/default/files]') }
          end
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_password'/) }
      end
    end
  end
end
