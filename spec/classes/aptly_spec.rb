require 'spec_helper'

describe 'profiles::aptly' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with api_hostname => aptly.example.com and certificate => wildcard.example.com" do
        let(:params) { {
          'api_hostname' => 'aptly.example.com',
          'certificate'  => 'wildcard.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('aptly') }
        it { is_expected.to contain_user('aptly') }
        it { is_expected.to contain_package('graphviz') }
        it { is_expected.to contain_profiles__apt__update('aptly') }

        it { is_expected.to have_gnupg_key_resource_count(0) }
        it { is_expected.to have_aptly__repo_resource_count(0) }

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
          's3_publish_endpoints' => {}
        )}

        it { is_expected.to contain_profiles__apache__vhost__redirect('http://aptly.example.com').with(
          'destination' => 'https://aptly.example.com'
        )}

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('https://aptly.example.com').with(
          'certificate' => 'wildcard.example.com',
          'destination' => 'http://127.0.0.1:8081/'
        )}

        case facts[:os]['release']['major']
        when '14.04'

          it { is_expected.to have_systemd__unit_file_resource_count(0) }
        when '16.04'

          it { is_expected.to contain_systemd__unit_file('aptly-api.service').with(
            'enable' => true,
            'active' => true
          ) }

          it { is_expected.to contain_systemd__unit_file('aptly-api.service').with_content(/WorkingDirectory=\/var\/aptly/) }
          it { is_expected.to contain_systemd__unit_file('aptly-api.service').with_content(/ExecStart=\/usr\/bin\/aptly api serve -listen=127.0.0.1:8081 -no-lock/) }

          it { is_expected.to contain_systemd__unit_file('aptly-api.service').that_requires('Class[aptly]') }
        end

        it { is_expected.to contain_class('aptly').that_requires('User[aptly]') }
        it { is_expected.to contain_class('aptly').that_requires('Profiles::Apt::Update[aptly]') }
      end

      context "with api_hostname => foobar.example.com and certificate => foobar.example.com" do
        let(:params) { {
          'api_hostname' => 'foobar.example.com',
          'certificate'  => 'foobar.example.com'
        } }

        context "with signing_keys => { 'test' => { 'id' => '1234ABCD', 'source' => '/tmp/test.key' }}, version => 1.2.3, data_dir => '/data/aptly', api_bind => 1.2.3.4, api_port => 8080 and repositories => [ 'foo', 'bar']" do
          let(:params) { super().merge(
            {
              'signing_keys' => { 'test' => { 'id' => '1234ABCD', 'source' => '/tmp/test.key' }},
              'version'      => '1.2.3',
              'data_dir'     => '/data/aptly',
              'api_bind'     => '1.2.3.4',
              'api_port'     => 8080,
              'repositories' => [ 'foo', 'bar']
            }
          )}

          it { is_expected.to contain_gnupg_key('test').with(
            'ensure'     => 'present',
            'key_id'     => '1234ABCD',
            'user'       => 'aptly',
            'key_source' => '/tmp/test.key',
            'key_type'   => 'private'
          ) }

          it { is_expected.to contain_class('aptly').with(
            'version'  => '1.2.3',
            'root_dir' => '/data/aptly',
            'api_bind' => '1.2.3.4',
            'api_port' => 8080
          ) }

          it { is_expected.to contain_profiles__apache__vhost__redirect('http://foobar.example.com').with(
            'destination' => 'https://foobar.example.com'
          )}

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('https://foobar.example.com').with(
            'certificate' => 'foobar.example.com',
            'destination' => 'http://1.2.3.4:8080/'
          )}

          it { is_expected.to contain_aptly__repo('foo').with(
            'default_component' => 'main'
          ) }

          case facts[:os]['release']['major']
          when '16.04'

            it { is_expected.to contain_systemd__unit_file('aptly-api.service').with_content(/WorkingDirectory=\/data\/aptly/) }
            it { is_expected.to contain_systemd__unit_file('aptly-api.service').with_content(/ExecStart=\/usr\/bin\/aptly api serve -listen=1.2.3.4:8080 -no-lock/) }
          end

          it { is_expected.to contain_gnupg_key('test').that_requires('User[aptly]') }
        end

        context "with signing_keys => { 'test1' => { 'id' => '6789DEFG', 'source' => '/tmp/test1.key' }, 'test2' => { 'id' => '1234ABCD', 'source' => '/tmp/test2.key' }}, publish_endpoints => { 'apt1' => { 'region' => 'eu-west-1', bucket => 'apt1', awsAccessKeyID => '123', awsSecretAccessKey => 'abc' }} and repositories => 'baz'" do
          let(:params) { super().merge(
            {
              'signing_keys'      => {
                 'test1' => { 'id' => '6789DEFG', 'source' => '/tmp/test1.key' },
                 'test2' => { 'id' => '1234ABCD', 'source' => '/tmp/test2.key' }
               },
              'publish_endpoints' => {
                 'apt1' => {
                   'region' => 'eu-west-1',
                   'bucket' => 'apt1',
                   'awsAccessKeyID' => '123',
                   'awsSecretAccessKey' => 'abc'
                 }
               },
              'repositories'      => 'baz'
            }
          ) }

          it { is_expected.to contain_gnupg_key('test1').with(
            'ensure'     => 'present',
            'key_id'     => '6789DEFG',
            'user'       => 'aptly',
            'key_source' => '/tmp/test1.key',
            'key_type'   => 'private'
          ) }

          it { is_expected.to contain_gnupg_key('test2').with(
            'ensure'     => 'present',
            'key_id'     => '1234ABCD',
            'user'       => 'aptly',
            'key_source' => '/tmp/test2.key',
            'key_type'   => 'private'
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
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'api_hostname'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'certificate'/) }
      end
    end
  end
end
