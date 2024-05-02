describe 'profiles::aptly' do
  let(:hiera_config) { 'spec/support/hiera/common.yaml' }

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with api_hostname => aptly.example.com and certificate => wildcard.example.com" do
        let(:params) { {
          'api_hostname' => 'aptly.example.com',
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::aptly').with(
          'api_hostname'      => 'aptly.example.com',
          'certificate'       => nil,
          'signing_keys'      => {},
          'trusted_keys'      => {},
          'version'           => 'latest',
          'api_bind'          => '127.0.0.1',
          'api_port'          => 8081,
          'lvm'               => false,
          'volume_group'      => nil,
          'volume_size'       => nil,
          'publish_endpoints' => {},
          'repositories'      => {},
          'mirrors'           => {}
        ) }

        it { is_expected.to contain_group('aptly') }
        it { is_expected.to contain_user('aptly') }
        it { is_expected.to contain_package('graphviz') }
        it { is_expected.to contain_apt__key('aptly') }
        it { is_expected.to contain_apt__source('aptly') }

        it { is_expected.to have_gnupg_key_resource_count(0) }

        it { is_expected.not_to contain_profiles__lvm__mount('aptlydata') }
        it { is_expected.not_to contain_mount('/var/aptly') }

        it { is_expected.to contain_class('aptly').with(
          'version'              => 'latest',
          'install_repo'         => false,
          'manage_user'          => false,
          'user'                 => 'aptly',
          'group'                => 'aptly',
          'root_dir'             => '/var/aptly',
          'enable_service'       => false,
          'enable_api'           => true,
          'api_bind'             => '127.0.0.1',
          'api_port'             => '8081',
          'api_nolock'           => true,
          'architectures'        => ['amd64'],
          's3_publish_endpoints' => {}
        ) }

        it { is_expected.to_not contain_profiles__apache__vhost__redirect('http://foobar.example.com') }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://aptly.example.com').with(
          'destination'  => 'http://127.0.0.1:8081/',
          'proxy_params' => { 'timeout' => 3600 }
        ) }

        it { is_expected.to contain_cron('aptly db cleanup daily').with(
          'environment' => [ 'MAILTO=infra@publiq.be'],
          'command'     => '/usr/bin/aptly db cleanup',
          'user'        => 'aptly',
          'hour'        => '4',
          'minute'      => '0'
        ) }

        it { is_expected.to contain_systemd__unit_file('aptly-api.service').with(
          'enable' => true,
          'active' => true
        ) }

        it { is_expected.to contain_systemd__unit_file('aptly-api.service').with_content(/WorkingDirectory=\/var\/aptly/) }
        it { is_expected.to contain_systemd__unit_file('aptly-api.service').with_content(/ExecStart=\/usr\/bin\/aptly api serve -listen=127.0.0.1:8081 -no-lock/) }

        it { is_expected.to contain_systemd__unit_file('aptly-api.service').that_requires('Class[aptly]') }

        it { is_expected.to contain_class('aptly').that_requires('User[aptly]') }

        it { is_expected.to contain_apt__key('aptly').that_comes_before('Apt::Source[aptly]') }
        it { is_expected.to contain_class('aptly').that_requires('Apt::Source[aptly]') }

        it { is_expected.to contain_cron('aptly db cleanup daily').that_requires('Class[aptly]') }
        it { is_expected.to contain_cron('aptly db cleanup daily').that_requires('User[aptly]') }

        it { is_expected.not_to contain_file('aptly trustedkeys.gpg') }
      end

      context "with api_hostname => foobar.example.com and certificate => foobar.example.com" do
        let(:params) { {
          'api_hostname' => 'foobar.example.com',
          'certificate'  => 'foobar.example.com'
        } }

        context "with signing_keys => { 'test' => { 'id' => '1234ABCD', 'content' => '-----BEGIN PGP PRIVATE KEY BLOCK-----\nmysigningkey\n-----END PGP PRIVATE KEY BLOCK-----' }}, trusted_keys => { 'Ubuntu archive' => { 'key_id' => '00001234', 'key_server' => 'hkp://keyserver.ubuntu.com' }}, version => 1.2.3, api_bind => 1.2.3.4, api_port => 8080, repositories => { 'foo' => {'archive' => false}, 'bar' => {'archive' => true}} and mirrors => {'mirror' => {'location => 'http://mirror.example.com', distribution => 'unstable', components => ['main', 'contrib'], keys => 'Ubuntu archive', architectures => 'amd64'}}, lvm => true, volume_group => myvg and volume_size => 10G" do
          let(:params) { super().merge(
            {
              'signing_keys' => { 'test' => { 'id' => '1234ABCD', 'content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\nmysigningkey\n-----END PGP PRIVATE KEY BLOCK-----" }},
              'trusted_keys' => { 'Ubuntu archive' => { 'key_id' => '00001234', 'key_server' => 'hkp://keyserver.ubuntu.com' }},
              'version'      => '1.2.3',
              'api_bind'     => '1.2.3.4',
              'api_port'     => 8080,
              'repositories' => {'foo' => { 'archive' => false }, 'bar' => { 'archive' => true }},
              'lvm'          => true,
              'volume_group' => 'myvg',
              'volume_size'  => '10G',
              'mirrors'      => { 'mymirror' => {
                                                   'location'      => 'http://mymirror.example.com',
                                                   'distribution'  => 'unstable',
                                                   'components'    => ['main', 'contrib'],
                                                   'keys'          => 'Ubuntu archive',
                                                   'architectures' => 'amd64',
                                                }
                                }
            }
          ) }

          context "with volume_group myvg present" do
            let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

            it { is_expected.to contain_profiles__lvm__mount('aptlydata').with(
              'volume_group' => 'myvg',
              'size'         => '10G',
              'mountpoint'   => '/data/aptly',
              'fs_type'      => 'ext4',
              'owner'        => 'aptly',
              'group'        => 'aptly'
            ) }

            it { is_expected.to contain_mount('/var/aptly').with(
              'ensure'  => 'mounted',
              'device'  => '/data/aptly',
              'fstype'  => 'none',
              'options' => 'rw,bind'
            ) }

            it { is_expected.to contain_gnupg_key('test').with(
              'ensure'      => 'present',
              'key_id'      => '1234ABCD',
              'user'        => 'aptly',
              'key_content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\nmysigningkey\n-----END PGP PRIVATE KEY BLOCK-----",
              'key_type'    => 'private'
            ) }

            it { is_expected.to contain_class('aptly').with(
              'version'  => '1.2.3',
              'root_dir' => '/var/aptly',
              'api_bind' => '1.2.3.4',
              'api_port' => 8080
            ) }

            it { is_expected.to contain_profiles__apache__vhost__redirect('http://foobar.example.com').with(
              'destination' => 'https://foobar.example.com'
            ) }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('https://foobar.example.com').with(
              'certificate'  => 'foobar.example.com',
              'destination'  => 'http://1.2.3.4:8080/',
              'proxy_params' => { 'timeout' => 3600 }
            ) }

            it { is_expected.to contain_aptly__repo('foo').with(
              'default_component' => 'main'
            ) }

            it { is_expected.not_to contain_aptly__repo('foo-archive') }

            it { is_expected.to contain_aptly__repo('bar').with(
              'default_component' => 'main'
            ) }

            it { is_expected.to contain_aptly__repo('bar-archive').with(
              'default_component' => 'main'
            ) }

            it { is_expected.to contain_file('aptly trustedkeys.gpg').with(
              'ensure' => 'link',
              'path'   => '/home/aptly/.gnupg/trustedkeys.gpg',
              'target' => '/home/aptly/.gnupg/pubring.kbx',
              'owner'  => 'aptly',
              'group'  => 'aptly',
            ) }

            it { is_expected.to contain_aptly__mirror('mymirror').with(
              'location'      => 'http://mymirror.example.com',
              'distribution'  => 'unstable',
              'components'    => ['main', 'contrib'],
              'architectures' => ['amd64'],
              'update'        => false,
              'keyring'       => '/home/aptly/.gnupg/trustedkeys.gpg'
            ) }

            it { is_expected.to contain_profiles__aptly__gpgkey('Ubuntu archive').with(
              'key_id'     => '00001234',
              'key_server' => 'hkp://keyserver.ubuntu.com'
            ) }

            it { is_expected.to contain_systemd__unit_file('aptly-api.service').with_content(/ExecStart=\/usr\/bin\/aptly api serve -listen=1.2.3.4:8080 -no-lock/) }

            it { is_expected.to contain_profiles__lvm__mount('aptlydata').that_comes_before('Class[aptly]') }
            it { is_expected.to contain_mount('/var/aptly').that_requires('Class[aptly]') }
            it { is_expected.to contain_mount('/var/aptly').that_comes_before('Aptly::Repo[bar]') }
            it { is_expected.to contain_mount('/var/aptly').that_comes_before('Aptly::Repo[bar-archive]') }
            it { is_expected.to contain_mount('/var/aptly').that_comes_before('Aptly::Mirror[mymirror]') }
            it { is_expected.to contain_gnupg_key('test').that_requires('User[aptly]') }
            it { is_expected.to contain_profiles__aptly__gpgkey('Ubuntu archive').that_comes_before('File[aptly trustedkeys.gpg]') }
            it { is_expected.to contain_aptly__repo('bar-archive').that_requires('Aptly::Repo[bar]') }
            it { is_expected.to contain_aptly__mirror('mymirror').that_requires('File[aptly trustedkeys.gpg]') }
            it { is_expected.to contain_aptly__mirror('mymirror').that_requires('Profiles::Aptly::Gpgkey[Ubuntu archive]') }
          end
        end

        context "with signing_keys => { 'test1' => { 'id' => '6789DEFD', 'content' => '-----BEGIN PGP PRIVATE KEY BLOCK-----\nsigningkey1\n-----END PGP PRIVATE KEY BLOCK----' }, 'test2' => { 'id' => '1234ABCD', 'content' => '-----BEGIN PGP PRIVATE KEY BLOCK-----\nsigningkey2\n-----END PGP PRIVATE KEY BLOCK----' }}, trusted_keys => { 'Ubuntu archive' => { 'key_id' => '12340000', 'key_server' => 'hkp://keyserver.ubuntu.com' }, 'docker1' => { 'key_id' => '56780000', 'key_source' => 'https://download.docker.com/linux/ubuntu/gpg1'}, 'docker2' => { 'key_id' => '56780001', 'key_source' => 'https://download.docker.com/linux/ubuntu/gpg2'}}, publish_endpoints => { 'apt1' => { 'region' => 'eu-west-1', bucket => 'apt1', awsAccessKeyID => '123', awsSecretAccessKey => 'abc' }}, repositories => { 'baz' => {}} and mirrors => { 'mirror1' => { 'location' => 'http://mirror1.example.com', distribution => 'testing', components => 'nonfree', keys => 'Ubuntu archive'}, 'mirror2' => { location => 'http://mirror2.example.com', 'distribution' => 'stable', 'components' => ['bar', 'baz'], 'keys' => ['docker1', 'docker2'], architectures => ['amd64'] }}, lvm => true, volume_group => 'mydatavg' and volume_size => 100G" do
          let(:params) { super().merge(
            {
              'signing_keys'      => {
                'test1' => { 'id' => '6789DEFD', 'content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\nsigningkey1\n-----END PGP PRIVATE KEY BLOCK----" },
                'test2' => { 'id' => '1234ABCD', 'content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\nsigningkey2\n-----END PGP PRIVATE KEY BLOCK----" }
              },
              'trusted_keys'      => {
                'Ubuntu archive' => { 'key_id' => '12340000', 'key_server' => 'hkp://keyserver.ubuntu.com' },
                'docker 1'       => { 'key_id' => '56780000', 'key_source' => 'https://download.docker.com/linux/ubuntu/gpg1' },
                'docker 2'       => { 'key_id' => '56780001', 'key_source' => 'https://download.docker.com/linux/ubuntu/gpg2' }
              },
              'lvm'               => true,
              'volume_group'      => 'mydatavg',
              'volume_size'       => '100G',
              'publish_endpoints' => {
                 'apt1' => {
                   'region' => 'eu-west-1',
                   'bucket' => 'apt1',
                   'awsAccessKeyID' => '123',
                   'awsSecretAccessKey' => 'abc'
                 }
              },
              'repositories'      => {'baz' => {} },
              'mirrors'           => { 'mirror1' => {
                                                      'location'      => 'http://mirror1.example.com' ,
                                                      'distribution'  => 'testing',
                                                      'components'    => 'nonfree',
                                                      'keys'          => 'Ubuntu archive',
                                                      'architectures' => ['arm64', 'amd64'],
                                                    },
                                       'mirror2' => {
                                                      'location'      => 'http://mirror2.example.com',
                                                      'distribution'  => 'stable',
                                                      'components'    => ['bar', 'baz'],
                                                      'keys'          => ['docker 1', 'docker 2'],
                                                      'architectures' => 'arm64',
                                                    }
                                     }
            }
          ) }

          context "with volume_group myvg present" do
            let(:pre_condition) { 'volume_group { "mydatavg": ensure => "present" }' }

            it { is_expected.to contain_profiles__lvm__mount('aptlydata').with(
              'volume_group' => 'mydatavg',
              'size'         => '100G',
              'mountpoint'   => '/data/aptly',
              'fs_type'      => 'ext4',
              'owner'        => 'aptly',
              'group'        => 'aptly'
            ) }

            it { is_expected.to contain_mount('/var/aptly').with(
              'ensure'  => 'mounted',
              'device'  => '/data/aptly',
              'fstype'  => 'none',
              'options' => 'rw,bind'
            ) }

            it { is_expected.to contain_gnupg_key('test1').with(
              'ensure'      => 'present',
              'key_id'      => '6789DEFD',
              'user'        => 'aptly',
              'key_content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\nsigningkey1\n-----END PGP PRIVATE KEY BLOCK----",
              'key_type'    => 'private'
            ) }

            it { is_expected.to contain_gnupg_key('test2').with(
              'ensure'      => 'present',
              'key_id'      => '1234ABCD',
              'user'        => 'aptly',
              'key_content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\nsigningkey2\n-----END PGP PRIVATE KEY BLOCK----",
              'key_type'    => 'private'
            ) }

            it { is_expected.to contain_class('aptly').with(
              's3_publish_endpoints' => { 'apt1' => {
                                            'region' => 'eu-west-1',
                                            'bucket' => 'apt1',
                                            'awsAccessKeyID' => '123',
                                            'awsSecretAccessKey' => 'abc'
                                          }
                                        }
            ) }

            it { is_expected.to contain_aptly__repo('baz').with(
              'default_component' => 'main'
            ) }

            it { is_expected.not_to contain_aptly__repo('baz-archive') }

            it { is_expected.to contain_file('aptly trustedkeys.gpg').with(
              'ensure' => 'link',
              'path'   => '/home/aptly/.gnupg/trustedkeys.gpg',
              'target' => '/home/aptly/.gnupg/pubring.kbx',
              'owner'  => 'aptly',
              'group'  => 'aptly',
            ) }

            it { is_expected.to contain_aptly__mirror('mirror1').with(
              'location'      => 'http://mirror1.example.com',
              'distribution'  => 'testing',
              'components'    => ['nonfree'],
              'architectures' => ['arm64', 'amd64'],
              'update'        => false,
              'keyring'       => '/home/aptly/.gnupg/trustedkeys.gpg'
            ) }

            it { is_expected.to contain_aptly__mirror('mirror2').with(
              'location'      => 'http://mirror2.example.com',
              'distribution'  => 'stable',
              'components'    => ['bar', 'baz'],
              'architectures' => ['arm64'],
              'update'        => false,
              'keyring'       => '/home/aptly/.gnupg/trustedkeys.gpg'
            ) }

            it { is_expected.to contain_profiles__aptly__gpgkey('Ubuntu archive').with(
              'key_id'     => '12340000',
              'key_server' => 'hkp://keyserver.ubuntu.com'
            ) }

            it { is_expected.to contain_profiles__aptly__gpgkey('docker 1').with(
              'key_id'     => '56780000',
              'key_source' => 'https://download.docker.com/linux/ubuntu/gpg1'
            ) }

            it { is_expected.to contain_profiles__aptly__gpgkey('docker 2').with(
              'key_id'     => '56780001',
              'key_source' => 'https://download.docker.com/linux/ubuntu/gpg2'
            ) }

            it { is_expected.to contain_profiles__aptly__gpgkey('Ubuntu archive').that_comes_before('File[aptly trustedkeys.gpg]') }
            it { is_expected.to contain_profiles__aptly__gpgkey('docker 1').that_comes_before('File[aptly trustedkeys.gpg]') }
            it { is_expected.to contain_profiles__aptly__gpgkey('docker 2').that_comes_before('File[aptly trustedkeys.gpg]') }
            it { is_expected.to contain_mount('/var/aptly').that_comes_before('Aptly::Repo[baz]') }
            it { is_expected.to contain_mount('/var/aptly').that_comes_before('Aptly::Mirror[mirror1]') }
            it { is_expected.to contain_mount('/var/aptly').that_comes_before('Aptly::Mirror[mirror2]') }
            it { is_expected.to contain_aptly__mirror('mirror1').that_requires('File[aptly trustedkeys.gpg]') }
            it { is_expected.to contain_aptly__mirror('mirror1').that_requires('Profiles::Aptly::Gpgkey[Ubuntu archive]') }
            it { is_expected.to contain_aptly__mirror('mirror2').that_requires('File[aptly trustedkeys.gpg]') }
          end
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'api_hostname'/) }
      end
    end
  end
end
