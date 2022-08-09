require 'spec_helper'

describe 'profiles::jenkins::controller' do

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:hiera_config) { 'spec/support/hiera/hiera.yaml' }

      context "with url => https://jenkins.example.com/ and admin_password => passw0rd" do
        let(:params) { {
          'url'            => 'https://jenkins.example.com/',
          'admin_password' => 'passw0rd'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::jenkins::controller').with(
          'url'                          => 'https://jenkins.example.com/',
          'admin_password'               => 'passw0rd',
          'version'                      => 'latest',
          'certificate'                  => nil,
          'docker_registry_url'          => nil,
          'docker_registry_credentialid' => nil,
          'credentials'                  => [],
          'global_libraries'             => [],
          'pipelines'                    => [],
          'users'                        => []
        ) }

        it { is_expected.to contain_class('profiles::java') }

        it { is_expected.to contain_class('profiles::jenkins::controller::install').with(
          'version' => 'latest'
        ) }

        it { is_expected.to contain_class('profiles::jenkins::controller::configuration').with(
          'url'                          => 'https://jenkins.example.com/',
          'admin_password'               => 'passw0rd',
          'docker_registry_url'          => nil,
          'docker_registry_credentialid' => nil,
          'credentials'                  => [],
          'global_libraries'             => [],
          'users'                        => []
        ) }

        it { is_expected.to contain_class('profiles::jenkins::controller::service') }

        it { is_expected.to contain_class('profiles::jenkins::cli').with(
          'version'        => 'latest',
          'controller_url' => 'https://jenkins.example.com/'
        ) }

        it { is_expected.to_not contain_profiles__apache__vhost__redirect('http://jenkins.example.com') }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://jenkins.example.com').with(
          'destination'           => 'http://127.0.0.1:8080/',
          'preserve_host'         => true,
          'allow_encoded_slashes' => 'nodecode',
          'proxy_keywords'        => 'nocanon',
          'support_websockets'    => true
        ) }

        it { is_expected.to contain_class('profiles::jenkins::controller::install').that_requires('Class[profiles::java]') }
        it { is_expected.to contain_class('profiles::jenkins::controller::install').that_notifies('Class[profiles::jenkins::controller::service]') }
        it { is_expected.to contain_class('profiles::jenkins::controller::configuration').that_requires('Class[profiles::jenkins::controller::service]') }
        it { is_expected.to contain_class('profiles::jenkins::controller::configuration').that_requires('Class[profiles::jenkins::cli]') }
        it { is_expected.to contain_class('profiles::jenkins::cli').that_requires('Profiles::Apache::Vhost::Reverse_proxy[http://jenkins.example.com]') }
      end

      context "with url => https://foobar.example.com/, admin_password => letmein, certificate => foobar.example.com, version => 1.2.3, docker_registry_url => https://my.docker.registry.com/, docker_registry_credentialid => my_docker_cred, credentials => [{ id => 'token1', type => 'string', secret => 'secret1'}, { id => 'token2', type => 'string', secret => 'secret2'}], global_libraries => [{'git_url' => 'git@foo.com:bar/baz.git', 'git_ref' => 'develop', 'credential_id' => 'gitkey'}, {'git_url' => 'git@example.com:org/repo.git', 'git_ref' => 'main', 'credential_id' => 'mygitcred'}], pipelines => [{ 'name' => 'baz', 'git_url' => 'git@github.com:bar/baz.git', 'git_ref' => 'refs/heads/develop', 'credential_id' => 'gitkey', keep_builds => 10 }, { 'name' => 'repo', 'git_url' => 'git@example.com:org/repo.git', 'git_ref' => 'main', 'credential_id' => 'mygitcred', keep_builds => '2' }] and users => [{'id' => 'foo', 'name' => 'Foo Bar', 'password' => 'baz', 'email' => 'foo@example.com'}, {'id' => 'user1', 'name' => 'User One', 'password' => 'passw0rd', 'email' => 'user1@example.com'}]" do
        let(:params) { {
          'url'                          => 'https://foobar.example.com/',
          'admin_password'               => 'letmein',
          'certificate'                  => 'foobar.example.com',
          'version'                      => '1.2.3',
          'docker_registry_url'          => 'https://my.docker.registry.com/',
          'docker_registry_credentialid' => 'my_docker_cred',
          'credentials'                  => [
                                              { 'id' => 'token1', 'type' => 'string', 'secret' => 'secret1'},
                                              { 'id' => 'token2', 'type' => 'string', 'secret' => 'secret2'}
                                            ],
          'global_libraries'             => [
                                              {
                                                'git_url'       => 'git@foo.com:bar/baz.git',
                                                'git_ref'       => 'develop',
                                                'credential_id' => 'gitkey'
                                              },
                                              {
                                                'git_url'       => 'git@example.com:org/repo.git',
                                                'git_ref'       => 'main',
                                                'credential_id' => 'mygitcred'
                                              }
                                            ],
          'pipelines'                    => [
                                              {
                                                'name'          => 'baz',
                                                'git_url'       => 'git@github.com:bar/baz.git',
                                                'git_ref'       => 'refs/heads/develop',
                                                'credential_id' => 'gitkey',
                                                'keep_builds'   => 10
                                              },
                                              {
                                                'name'          => 'repo',
                                                'git_url'       => 'git@example.com:org/repo.git',
                                                'git_ref'       => 'main',
                                                'credential_id' => 'mygitcred',
                                                'keep_builds'   => 2
                                              }
                                            ],
          'users'                        => [
                                              {'id' => 'foo', 'name' => 'Foo Bar', 'password' => 'baz', 'email' => 'foo@example.com'},
                                              {'id' => 'user1', 'name' => 'User One', 'password' => 'passw0rd', 'email' => 'user1@example.com'}
                                            ]
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::jenkins::controller::install').with(
          'version' => '1.2.3'
        ) }

        it { is_expected.to contain_class('profiles::jenkins::controller::configuration').with(
          'url'                          => 'https://foobar.example.com/',
          'admin_password'               => 'letmein',
          'docker_registry_url'          => 'https://my.docker.registry.com/',
          'docker_registry_credentialid' => 'my_docker_cred',
          'credentials'                  => [
                                              { 'id' => 'token1', 'type' => 'string', 'secret' => 'secret1'},
                                              { 'id' => 'token2', 'type' => 'string', 'secret' => 'secret2'}
                                            ],
          'global_libraries' =>             [
                                              {
                                                'git_url'       => 'git@foo.com:bar/baz.git',
                                                'git_ref'       => 'develop',
                                                'credential_id' => 'gitkey'
                                              },
                                              {
                                                'git_url'       => 'git@example.com:org/repo.git',
                                                'git_ref'       => 'main',
                                                'credential_id' => 'mygitcred'
                                              }
                                            ],
          'pipelines'                    => [
                                              {
                                                'name'          => 'baz',
                                                'git_url'       => 'git@github.com:bar/baz.git',
                                                'git_ref'       => 'refs/heads/develop',
                                                'credential_id' => 'gitkey',
                                                'keep_builds'   => 10
                                              },
                                              {
                                                'name'          => 'repo',
                                                'git_url'       => 'git@example.com:org/repo.git',
                                                'git_ref'       => 'main',
                                                'credential_id' => 'mygitcred',
                                                'keep_builds'   => 2
                                              }
                                            ],
          'users'                        => [
                                              {'id' => 'foo', 'name' => 'Foo Bar', 'password' => 'baz', 'email' => 'foo@example.com'},
                                              {'id' => 'user1', 'name' => 'User One', 'password' => 'passw0rd', 'email' => 'user1@example.com'}
                                            ]
        ) }

        it { is_expected.to contain_class('profiles::jenkins::cli').with(
          'version'        => '1.2.3',
          'controller_url' => 'https://foobar.example.com/'
        ) }

        it { is_expected.to contain_profiles__apache__vhost__redirect('http://foobar.example.com').with(
          'destination' => 'https://foobar.example.com'
        ) }

        it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('https://foobar.example.com').with(
          'destination'           => 'http://127.0.0.1:8080/',
          'certificate'           => 'foobar.example.com',
          'preserve_host'         => true,
          'allow_encoded_slashes' => 'nodecode',
          'proxy_keywords'        => 'nocanon',
          'support_websockets'    => true
        ) }

        it { is_expected.to contain_class('profiles::jenkins::cli').that_requires('Profiles::Apache::Vhost::Reverse_proxy[https://foobar.example.com]') }
      end

      context "without parameters and without hieradata" do
        let(:params) { {} }
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'url'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_password'/) }
      end
    end
  end
end
