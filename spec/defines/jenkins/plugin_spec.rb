require 'spec_helper'

describe 'profiles::jenkins::plugin' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with title foobar" do
        let(:title) { 'foobar' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__jenkins__plugin('foobar').with(
            'ensure'        => 'present',
            'restart'       => false,
            'configuration' => nil
          ) }

          it { is_expected.to contain_class('profiles::jenkins::cli') }

          it { is_expected.to contain_exec('jenkins plugin foobar').with(
            'command'   => "jenkins-cli install-plugin foobar -deploy",
            'path'      => [ '/usr/local/bin', '/usr/bin', '/bin'],
            'unless'    => 'jenkins-cli list-plugins foobar',
            'tries'     => 5,
            'try_sleep' => 10,
            'logoutput' => 'on_failure'
            )
          }

          it { is_expected.to_not contain_group('jenkins') }
          it { is_expected.to_not contain_user('jenkins') }
          it { is_expected.to_not contain_file('foobar configuration') }

          it { is_expected.to contain_exec('jenkins plugin foobar').that_requires('Class[profiles::jenkins::cli]') }
        end

        context "with ensure => absent" do
          let(:params) { {
            'ensure' => 'absent',
          } }

          it { is_expected.to contain_exec('jenkins plugin foobar').with(
            'command'   => "jenkins-cli disable-plugin foobar -restart",
            'path'      => [ '/usr/local/bin', '/usr/bin', '/bin'],
            'onlyif'    => 'jenkins-cli list-plugins foobar',
            'tries'     => 5,
            'try_sleep' => 10,
            'logoutput' => 'on_failure'
            )
          }
        end
      end

      context "with title configuration-as-code" do
        let(:title) { 'configuration-as-code' }

        context "with restart => true and configuration => { 'url' => 'https://foobar.com/', 'admin_password' => 'passw0rd'}" do
          let(:params) { {
              'restart'       => true,
              'configuration' => { 'url' => 'https://foobar.com/', 'admin_password' => 'passw0rd'}
          } }

          it { is_expected.to contain_exec('jenkins plugin configuration-as-code').with(
            'command'   => "jenkins-cli install-plugin configuration-as-code -restart",
            'path'      => [ '/usr/local/bin', '/usr/bin', '/bin'],
            'unless'    => 'jenkins-cli list-plugins configuration-as-code',
            'tries'     => 5,
            'try_sleep' => 10,
            'logoutput' => 'on_failure'
            )
          }

          it { is_expected.to contain_group('jenkins') }
          it { is_expected.to contain_user('jenkins') }

          it { is_expected.to contain_file('configuration-as-code configuration').with(
            'ensure'  => 'file',
            'path'    => '/var/lib/jenkins/casc_config/configuration-as-code.yaml',
            'owner'   => 'jenkins',
            'group'   => 'jenkins'
          ) }

          it { is_expected.to contain_file('configuration-as-code configuration').with_content(/^\s*password: 'passw0rd'$/) }
          it { is_expected.to contain_file('configuration-as-code configuration').with_content(/^\s*url: 'https:\/\/foobar\.com\/'$/) }

          it { is_expected.to contain_file('configuration-as-code configuration').that_requires('Group[jenkins]') }
          it { is_expected.to contain_file('configuration-as-code configuration').that_requires('User[jenkins]') }
          it { is_expected.to contain_exec('jenkins plugin configuration-as-code').that_requires('Class[profiles::jenkins::cli]') }
        end

        context "with configuration => { 'url' => 'https://jenkins.example.com/', 'admin_password' => 'jenkins'}" do
          let(:params) { {
              'configuration' => { 'url' => 'https://jenkins.example.com/', 'admin_password' => 'jenkins'}
          } }

          it { is_expected.to contain_file('configuration-as-code configuration').with_content(/^\s*password: 'jenkins'$/) }
          it { is_expected.to contain_file('configuration-as-code configuration').with_content(/^\s*url: 'https:\/\/jenkins\.example\.com\/'$/) }
        end
      end

      context "with title plain-credentials" do
        let(:title) { 'plain-credentials' }

        context "with configuration => {'credentials' => {'id' => 'mytoken', 'type' => 'string', 'secret' => 'foobar'}}" do
          let(:params) { {
              'configuration' => { 'credentials' => {'id' => 'mytoken', 'type' => 'string', 'secret' => 'foobar'}}
          } }

          it { is_expected.to contain_file('plain-credentials configuration').with(
            'ensure'  => 'file',
            'path'    => '/var/lib/jenkins/casc_config/plain-credentials.yaml',
            'owner'   => 'jenkins',
            'group'   => 'jenkins'
          ) }

          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*id: 'mytoken'$/) }
          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*secret: 'foobar'$/) }
        end

        context "with configuration => {'credentials' => [{'id' => 'token1', 'type' => 'string', 'secret' => 'secret1'}, {'id' => 'token2', 'type' => 'string', 'secret' => 'secret2'}]}" do
          let(:params) { {
              'configuration' => { 'credentials' => [
                                    {'id' => 'token1', 'type' => 'string', 'secret' => 'secret1'},
                                    {'id' => 'token2', 'type' => 'string', 'secret' => 'secret2'}
                                   ]
                                 }
          } }

          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*id: 'token1'$/) }
          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*secret: 'secret1'$/) }

          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*id: 'token2'$/) }
          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*secret: 'secret2'$/) }
        end
      end

      context "with title ssh-credentials" do
        let(:title) { 'ssh-credentials' }

        context "with configuration => {'credentials' => {'id' => 'mykey', 'type' => 'private_key', 'key' => 'abc123'}}" do
          let(:params) { {
              'configuration' => { 'credentials' => {'id' => 'mykey', 'type' => 'private_key', 'key' => 'abc123'}}
          } }

          it { is_expected.to contain_file('ssh-credentials configuration').with(
            'ensure'  => 'file',
            'path'    => '/var/lib/jenkins/casc_config/ssh-credentials.yaml',
            'owner'   => 'jenkins',
            'group'   => 'jenkins'
          ) }

          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*id: 'mykey'$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*privateKey: 'abc123'$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*username: 'mykey'$/) }
        end

        context "with configuration => {'credentials' => [{'id' => 'key1', 'type' => 'private_key', 'key' => 'def456'}, {'id' => 'key2', 'type' => 'private_key', 'secret' => 'ghi789'}]}" do
          let(:params) { {
              'configuration' => { 'credentials' => [
                                    {'id' => 'key1', 'type' => 'private_key', 'key' => 'def456'},
                                    {'id' => 'key2', 'type' => 'private_key', 'key' => 'ghi789'}
                                   ]
                                 }
          } }

          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*id: 'key1'$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*privateKey: 'def456'$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*username: 'key1'$/) }

          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*id: 'key2'$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*privateKey: 'ghi789'$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*username: 'key2'$/) }
        end
      end
    end
  end
end
