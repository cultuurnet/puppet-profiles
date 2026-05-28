describe 'profiles::elasticsearch' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('elasticsearch') }
        it { is_expected.to contain_user('elasticsearch') }

        it { is_expected.to contain_class('profiles::elasticsearch').with(
          'major_version'                       => 5,
          'version'                             => nil,
          'lvm'                                 => false,
          'volume_group'                        => nil,
          'volume_size'                         => nil,
          'log_volume_size'                     => nil,
          'initial_heap_size'                   => '512m',
          'maximum_heap_size'                   => '512m',
          'backup'                              => true,
          'backup_lvm'                          => false,
          'backup_volume_group'                 => nil,
          'backup_volume_size'                  => nil,
          'backup_hour'                         => 0,
          'backup_retention_days'               => 7,
          'jvm_options'                         => [],
          'log_retention_days'                  => 7,
          'secure_remote_access'                => false,
          'secure_remote_access_user'           => nil,
          'secure_remote_access_password'       => nil,
          'secure_remote_access_plugin_version' => nil
        ) }

        it { is_expected.to contain_class('profiles::java') }

        it { is_expected.to contain_apt__source('elastic-5.x') }

        it { is_expected.not_to contain_profiles__lvm__mount('elasticsearchdata') }
        it { is_expected.not_to contain_mount('/data/elasticsearch') }

        it { is_expected.to contain_file('/var/lib/elasticsearch').with(
          'ensure' => 'directory',
          'owner'  => 'elasticsearch',
          'group'  => 'elasticsearch'
        ) }

        it { is_expected.to contain_augeas('elasticsearch-remove-heap-configuration-from-jvm.options').with(
          'lens'    => 'SimpleLines.lns',
          'incl'    => '/etc/elasticsearch/jvm.options',
          'context' => '/files/etc/elasticsearch/jvm.options',
          'changes' => [
                         "rm *[. =~ regexp('^-Xms.*')]",
                         "rm *[. =~ regexp('^-Xmx.*')]"
                       ]
        ) }

        it { is_expected.to contain_class('elasticsearch').with(
          'version'           => false,
          'manage_repo'       => false,
          'api_timeout'       => 30,
          'restart_on_change' => true,
          'datadir'           => '/var/lib/elasticsearch',
          'manage_datadir'    => false,
          'manage_logdir'     => true,
          'init_defaults'     => { 'ES_JAVA_OPTS' => '"-Xms512m -Xmx512m"' },
          'jvm_options'       => ['-XX:+IgnoreUnrecognizedVMOptions'],
          'plugins'           => {},
          'config'            => {}
        ) }

        it { is_expected.to contain_class('profiles::elasticsearch::backup').with(
          'schedule'       => true,
          'lvm'            => false,
          'volume_group'   => nil,
          'volume_size'    => nil,
          'dump_hour'      => 0,
          'retention_days' => 7
        ) }

        it { is_expected.to contain_cron('elasticsearch_log_retention').with(
          'environment' => ['MAILTO=infra+cron@publiq.be'],
          'command'     => '/usr/bin/find /var/log/elasticsearch -type f -name "*.log" -mtime +6 -exec rm {} \;',
          'hour'        => '0',
          'minute'      => '0'
        ) }

        it { is_expected.not_to contain_package('elasticsearch-readonlyrest') }
        it { is_expected.not_to contain_firewall('600 accept elasticsearch http traffic') }
        it { is_expected.not_to contain_firewall('600 accept elasticsearch cluster traffic') }

        it { is_expected.to contain_class('elasticsearch').that_requires('Apt::Source[elastic-5.x]') }
        it { is_expected.to contain_class('elasticsearch').that_requires('Class[profiles::java]') }
        it { is_expected.to contain_file('/var/lib/elasticsearch').that_requires('Group[elasticsearch]') }
        it { is_expected.to contain_file('/var/lib/elasticsearch').that_requires('User[elasticsearch]') }
        it { is_expected.to contain_file('/var/lib/elasticsearch').that_comes_before('Class[elasticsearch]') }
        it { is_expected.to contain_augeas('elasticsearch-remove-heap-configuration-from-jvm.options').that_requires('Class[elasticsearch::package]') }
        it { is_expected.to contain_augeas('elasticsearch-remove-heap-configuration-from-jvm.options').that_comes_before('Class[elasticsearch::config]') }
        it { is_expected.to contain_class('profiles::elasticsearch::backup').that_requires('Class[elasticsearch]') }
      end

      context "with backup => false" do
        let(:params) { {
          'backup' => false
        } }

        it { is_expected.to contain_class('profiles::elasticsearch::backup').with(
          'schedule'       => false,
          'lvm'            => false,
          'volume_group'   => nil,
          'volume_size'    => nil,
          'dump_hour'      => 0,
          'retention_days' => 7
        ) }
      end

      context "with version => 8.2.1, lvm => true, volume_group => myvg, volume_size => 20G, log_volume_size => 5G, initial_heap_size => 768m, maximum_heap_size => 1024m, backup_lvm => true, backup_volume_group => mybackupvg, backup_volume_size => 10G, backup_hour => 10, backup_retention_days => 5, jvm_options => -Xmixed, log_retention_days => 14, secure_remote_access => true, secure_remote_access_user => foo, secure_remote_access_password => bar and secure_remote_access_plugin_version => 3.2.1" do
        let(:params) { {
          'version'                             => '8.2.1',
          'lvm'                                 => true,
          'volume_group'                        => 'myvg',
          'volume_size'                         => '20G',
          'log_volume_size'                     => '5G',
          'initial_heap_size'                   => '768m',
          'maximum_heap_size'                   => '1024m',
          'backup_lvm'                          => true,
          'backup_volume_group'                 => 'mybackupvg',
          'backup_volume_size'                  => '10G',
          'backup_hour'                         => 10,
          'backup_retention_days'               => 5,
          'jvm_options'                         => '-Xmixed',
          'log_retention_days'                  => 14,
          'secure_remote_access'                => true,
          'secure_remote_access_user'           => 'foo',
          'secure_remote_access_password'       => 'bar',
          'secure_remote_access_plugin_version' => '3.2.1'
        } }

        context 'with fact networking.interfaces.eth0.ip => 10.0.0.1' do
          let(:facts) { super().merge({
            'networking' => { 'interfaces' => { 'eth0' => { 'ip' => '10.0.0.1' } } }
          }) }

          context "with volume_groups myvg and mybackupvg present" do
            let(:pre_condition) { ['volume_group { "myvg": ensure => "present" }', 'volume_group { "mybackupvg": ensure => "present" }'] }

            it { is_expected.to contain_apt__source('elastic-8.x') }

            it { is_expected.to contain_profiles__lvm__mount('elasticsearchdata').with(
              'volume_group' => 'myvg',
              'size'         => '20G',
              'mountpoint'   => '/data/elasticsearch',
              'fs_type'      => 'ext4',
              'owner'        => 'elasticsearch',
              'group'        => 'elasticsearch'
            ) }

            it { is_expected.to contain_mount('/var/lib/elasticsearch').with(
              'ensure'  => 'mounted',
              'device'  => '/data/elasticsearch',
              'fstype'  => 'none',
              'options' => 'rw,bind'
            ) }

            it { is_expected.to contain_file('/var/lib/elasticsearch').with(
              'ensure' => 'directory',
              'owner'  => 'elasticsearch',
              'group'  => 'elasticsearch'
            ) }

            it { is_expected.to contain_profiles__lvm__mount('elasticsearchlogs').with(
              'volume_group' => 'myvg',
              'size'         => '5G',
              'mountpoint'   => '/data/elasticsearchlogs',
              'fs_type'      => 'ext4',
              'owner'        => 'elasticsearch',
              'group'        => 'elasticsearch'
            ) }

            it { is_expected.to contain_mount('/var/log/elasticsearch').with(
              'ensure'  => 'mounted',
              'device'  => '/data/elasticsearchlogs',
              'fstype'  => 'none',
              'options' => 'rw,bind'
            ) }

            it { is_expected.to contain_file('/var/log/elasticsearch').with(
              'ensure' => 'directory',
              'owner'  => 'elasticsearch',
              'group'  => 'elasticsearch'
            ) }

            it { is_expected.to contain_class('elasticsearch').with(
              'version'           => '8.2.1',
              'manage_repo'       => false,
              'api_timeout'       => 30,
              'restart_on_change' => true,
              'datadir'           => '/var/lib/elasticsearch',
              'manage_datadir'    => false,
              'manage_logdir'     => false,
              'init_defaults'     => { 'ES_JAVA_OPTS' => '"-Xms768m -Xmx1024m"' },
              'jvm_options'       => ['-XX:+IgnoreUnrecognizedVMOptions', '-Xmixed'],
              'plugins'           => { 'readonlyrest' => {
                                                           'source' => '/opt/elasticsearch-readonlyrest/v3.2.1_es8.2.1.zip'
                                                         }
                                     },
              'config'            => {
                                       'xpack.security.enabled'                 => false,
                                       'xpack.security.transport.ssl.enabled'   => false,
                                       'xpack.security.http.ssl.enabled'        => false,
                                       'network.host'                           => ['10.0.0.1', '127.0.0.1'],
                                       'http.cors.enabled'                      => true,
                                       'http.cors.allow-origin'                 => '*',
                                       'http.cors.allow-methods'                => 'OPTIONS, HEAD, GET, POST, PUT, DELETE',
                                       'http.cors.allow-headers'                => 'X-Requested-With, X-Auth-Token, Content-Type, Content-Length',
                                       'readonlyrest.enable'                    => true,
                                       'readonlyrest.response_if_req_forbidden' => 'Access denied!!!',
                                       'readonlyrest.access_control_rules'      => [
                                         {
                                           'name'     => 'Accept all local requests without authentication',
                                           'type'     => 'allow',
                                           'hosts'    => ['127.0.0.1']
                                         },
                                         {
                                           'name'     => 'Accept all write requests with basic authentication',
                                           'auth_key' => 'foo:bar',
                                           'type'     => 'allow',
                                           'methods'  => ['POST','PUT','DELETE']
                                         },
                                         {
                                           'name'     => 'Accept all read requests without authentication',
                                           'type'     => 'allow',
                                           'indices'  => ['*'],
                                           'actions'  => ['indices:data/read/*']
                                         },
                                         {
                                           'name'     => 'Deny all write requests',
                                           'type'     => 'forbid',
                                           'indices'  => ['*'],
                                           'actions'  => ['indices:data/write/*']
                                         }
                                       ]
                                     }
            ) }

            it { is_expected.to contain_apt__source('publiq-tools') }
            it { is_expected.to contain_package('elasticsearch-readonlyrest').with(
              'ensure' => '3.2.1-es8.2.1'
            ) }

            it { is_expected.to contain_firewall('600 accept elasticsearch http traffic') }
            it { is_expected.to contain_firewall('600 accept elasticsearch cluster traffic') }

            it { is_expected.to contain_class('profiles::elasticsearch::backup').with(
              'schedule'       => true,
              'lvm'            => true,
              'volume_group'   => 'mybackupvg',
              'volume_size'    => '10G',
              'dump_hour'      => 10,
              'retention_days' => 5
            ) }

            it { is_expected.to contain_cron('elasticsearch_log_retention').with(
              'command'     => '/usr/bin/find /var/log/elasticsearch -type f -name "*.log" -mtime +13 -exec rm {} \;',
            ) }

            it { is_expected.to contain_profiles__lvm__mount('elasticsearchdata').that_requires('Group[elasticsearch]') }
            it { is_expected.to contain_profiles__lvm__mount('elasticsearchdata').that_requires('User[elasticsearch]') }
            it { is_expected.to contain_file('/var/lib/elasticsearch').that_requires('Group[elasticsearch]') }
            it { is_expected.to contain_file('/var/lib/elasticsearch').that_requires('User[elasticsearch]') }
            it { is_expected.to contain_file('/var/lib/elasticsearch').that_comes_before('Class[elasticsearch]') }
            it { is_expected.to contain_mount('/var/lib/elasticsearch').that_requires('Profiles::Lvm::Mount[elasticsearchdata]') }
            it { is_expected.to contain_mount('/var/lib/elasticsearch').that_requires('File[/var/lib/elasticsearch]') }
            it { is_expected.to contain_mount('/var/lib/elasticsearch').that_comes_before('Class[elasticsearch]') }
            it { is_expected.to contain_profiles__lvm__mount('elasticsearchlogs').that_requires('Group[elasticsearch]') }
            it { is_expected.to contain_profiles__lvm__mount('elasticsearchlogs').that_requires('User[elasticsearch]') }
            it { is_expected.to contain_file('/var/log/elasticsearch').that_requires('Group[elasticsearch]') }
            it { is_expected.to contain_file('/var/log/elasticsearch').that_requires('User[elasticsearch]') }
            it { is_expected.to contain_file('/var/log/elasticsearch').that_comes_before('Class[elasticsearch]') }
            it { is_expected.to contain_mount('/var/log/elasticsearch').that_requires('Profiles::Lvm::Mount[elasticsearchlogs]') }
            it { is_expected.to contain_mount('/var/log/elasticsearch').that_requires('File[/var/log/elasticsearch]') }
            it { is_expected.to contain_mount('/var/log/elasticsearch').that_comes_before('Class[elasticsearch]') }
            it { is_expected.to contain_class('elasticsearch').that_requires('Apt::Source[elastic-8.x]') }
            it { is_expected.to contain_package('elasticsearch-readonlyrest').that_requires('Apt::Source[publiq-tools]') }
            it { is_expected.to contain_package('elasticsearch-readonlyrest').that_comes_before('Class[elasticsearch]') }
          end
        end
      end

      context "with version => 5.2.2, lvm => true, volume_group => mydatavg, volume_size => 10G, backup_lvm => true, backup_volume_group => esbackupvg, backup_volume_size => 5G, backup_hour => 1, backup_retention_days => 10, jvm_options => [-Xmixed, -Xverify], log_retention_days => 0, secure_remote_access => true, secure_remote_access_user => baz, secure_remote_access_password => secret and secure_remote_access_plugin_version => 4.5.6" do
        let(:params) { {
          'version'                             => '5.2.2',
          'lvm'                                 => true,
          'volume_group'                        => 'mydatavg',
          'volume_size'                         => '10G',
          'backup_lvm'                          => true,
          'backup_volume_group'                 => 'esbackupvg',
          'backup_volume_size'                  => '5G',
          'backup_hour'                         => 1,
          'backup_retention_days'               => 10,
          'jvm_options'                         => ['-Xmixed', '-Xverify'],
          'log_retention_days'                  => 0,
          'secure_remote_access'                => true,
          'secure_remote_access_user'           => 'baz',
          'secure_remote_access_password'       => 'secret',
          'secure_remote_access_plugin_version' => '4.5.6'
        } }

        context 'with fact networking.interfaces.eth0.ip => 10.0.0.2' do
          let(:facts) { super().merge({
            'networking' => { 'interfaces' => { 'eth0' => { 'ip' => '10.0.0.2' } } }
          }) }

          context "with volume_groups mydatavg and esbackupvg present" do
            let(:pre_condition) { ['volume_group { "mydatavg": ensure => "present" }', 'volume_group { "esbackupvg": ensure => "present" }'] }

            it { is_expected.to contain_apt__source('elastic-5.x') }

            it { is_expected.to contain_profiles__lvm__mount('elasticsearchdata').with(
              'volume_group' => 'mydatavg',
              'size'         => '10G',
              'mountpoint'   => '/data/elasticsearch',
              'fs_type'      => 'ext4',
              'owner'        => 'elasticsearch',
              'group'        => 'elasticsearch'
            ) }

            it { is_expected.to contain_mount('/var/lib/elasticsearch').with(
              'ensure'  => 'mounted',
              'device'  => '/data/elasticsearch',
              'fstype'  => 'none',
              'options' => 'rw,bind'
            ) }

            it { is_expected.not_to contain_profiles__lvm__mount('elasticsearchlogs') }
            it { is_expected.not_to contain_mount('/var/log/elasticsearch') }

            it { is_expected.to contain_class('elasticsearch').with(
              'version'           => '5.2.2',
              'manage_repo'       => false,
              'api_timeout'       => 30,
              'restart_on_change' => true,
              'datadir'           => '/var/lib/elasticsearch',
              'manage_datadir'    => false,
              'manage_logdir'     => true,
              'init_defaults'     => { 'ES_JAVA_OPTS' => '"-Xms512m -Xmx512m"' },
              'jvm_options'       => ['-XX:+IgnoreUnrecognizedVMOptions', '-Xmixed', '-Xverify'],
              'plugins'           => { 'readonlyrest' => {
                                                           'source' => '/opt/elasticsearch-readonlyrest/v4.5.6_es5.2.2.zip'
                                                         }
                                     },
              'config'            => {
                                       'network.host'                           => ['10.0.0.2', '127.0.0.1'],
                                       'http.cors.enabled'                      => true,
                                       'http.cors.allow-origin'                 => '*',
                                       'http.cors.allow-methods'                => 'OPTIONS, HEAD, GET, POST, PUT, DELETE',
                                       'http.cors.allow-headers'                => 'X-Requested-With, X-Auth-Token, Content-Type, Content-Length',
                                       'readonlyrest.enable'                    => true,
                                       'readonlyrest.response_if_req_forbidden' => 'Access denied!!!',
                                       'readonlyrest.access_control_rules'      => [
                                         {
                                           'name'     => 'Accept all local requests without authentication',
                                           'type'     => 'allow',
                                           'hosts'    => ['127.0.0.1']
                                         },
                                         {
                                           'name'     => 'Accept all write requests with basic authentication',
                                           'auth_key' => 'baz:secret',
                                           'type'     => 'allow',
                                           'methods'  => ['POST','PUT','DELETE']
                                         },
                                         {
                                           'name'     => 'Accept all read requests without authentication',
                                           'type'     => 'allow',
                                           'indices'  => ['*'],
                                           'actions'  => ['indices:data/read/*']
                                         },
                                         {
                                           'name'     => 'Deny all write requests',
                                           'type'     => 'forbid',
                                           'indices'  => ['*'],
                                           'actions'  => ['indices:data/write/*']
                                         }
                                       ]
                                     }
            ) }

            it { is_expected.to contain_package('elasticsearch-readonlyrest').with(
              'ensure' => '4.5.6-es5.2.2'
            ) }

            it { is_expected.to contain_class('profiles::elasticsearch::backup').with(
              'schedule'       => true,
              'lvm'            => true,
              'volume_group'   => 'esbackupvg',
              'volume_size'    => '5G',
              'dump_hour'      => 1,
              'retention_days' => 10
            ) }

            it { is_expected.to contain_cron('elasticsearch_log_retention').with(
              'command'     => '/usr/bin/find /var/log/elasticsearch -type f -name "*.log" -mtime +0 -exec rm {} \;',
            ) }

            it { is_expected.to contain_class('elasticsearch').that_requires('Apt::Source[elastic-5.x]') }
          end
        end
      end

      context "with version => 8.2.1 and major_version => 5" do
        let(:params) { {
          'version'       => '8.2.1',
          'major_version' => 5
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /incompatible combination of 'version' and 'major_version' parameters/) }
      end

      context "with secure_remote_access => true" do
        let(:params) { {
          'secure_remote_access' => true
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /with secure_remote_access enabled, expects a value for 'secure_remote_access_user', 'secure_remote_access_password' and 'secure_remote_access_plugin_version'/) }
      end
    end
  end
end
