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

        context "with configuration => []" do
          let(:params) { {
            'configuration' => [],
          } }

          it { is_expected.to contain_profiles__jenkins__plugin('foobar').with(
            'ensure'        => 'present',
            'restart'       => false,
            'configuration' => []
          ) }

          it { is_expected.to_not contain_file('foobar configuration') }
        end

        context "with configuration => {}" do
          let(:params) { {
            'configuration' => {},
          } }

          it { is_expected.to contain_profiles__jenkins__plugin('foobar').with(
            'ensure'        => 'present',
            'restart'       => false,
            'configuration' => {}
          ) }

          it { is_expected.to_not contain_file('foobar configuration') }
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

        context "with configuration => [{'id' => 'mytoken', 'type' => 'string', 'secret' => 'foobar'}, {'id' => 'myfile', 'type' => 'file', 'filename' => 'my_file.txt', 'content' => 'spec testfile content'}]" do
          let(:params) { {
              'configuration' => [
                                   {'id' => 'mytoken', 'type' => 'string', 'secret' => 'foobar'},
                                   {'id' => 'myfile', 'type' => 'file', 'filename' => 'my_file.txt', 'content' => 'spec testfile content'}
                                 ]
          } }

          it { is_expected.to contain_file('plain-credentials configuration').with(
            'ensure'  => 'file',
            'path'    => '/var/lib/jenkins/casc_config/plain-credentials.yaml',
            'owner'   => 'jenkins',
            'group'   => 'jenkins'
          ) }

          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*id: 'mytoken'$/) }
          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*secret: 'foobar'$/) }

          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*id: 'myfile'$/) }
          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*secretBytes: 'spec testfile content'$/) }
          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*fileName: 'my_file.txt'$/) }
        end

        context "with configuration => [{'id' => 'token1', 'type' => 'string', 'secret' => 'secret1'}, {'id' => 'token2', 'type' => 'string', 'secret' => 'secret2'}, {'id' => 'myfile', 'type' => 'file', 'filename' => 'my_file2.txt', 'content' => 'spec testfile content'}]" do
          let(:params) { {
              'configuration' => [
                                   {'id' => 'token1', 'type' => 'string', 'secret' => 'secret1'},
                                   {'id' => 'token2', 'type' => 'string', 'secret' => 'secret2'},
                                   {'id' => 'myfile2', 'type' => 'file', 'filename' => 'my_file2.txt', 'content' => 'spec testfile content 2'}
                                 ]
          } }

          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*id: 'token1'$/) }
          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*secret: 'secret1'$/) }

          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*id: 'token2'$/) }
          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*secret: 'secret2'$/) }

          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*id: 'myfile2'$/) }
          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*secretBytes: 'spec testfile content 2'$/) }
          it { is_expected.to contain_file('plain-credentials configuration').with_content(/^\s*fileName: 'my_file2.txt'$/) }
        end
      end

      context "with title ssh-credentials" do
        let(:title) { 'ssh-credentials' }

        context "with configuration => {'credentials' => {'id' => 'mykey', 'type' => 'private_key', 'key' => 'abc123'}}" do
          let(:params) { {
              'configuration' => {'id' => 'mykey', 'type' => 'private_key', 'key' => "abc123\n"}
          } }

          it { is_expected.to contain_file('ssh-credentials configuration').with(
            'ensure'  => 'file',
            'path'    => '/var/lib/jenkins/casc_config/ssh-credentials.yaml',
            'owner'   => 'jenkins',
            'group'   => 'jenkins'
          ) }

          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*id: 'mykey'$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*privateKey: \|\n\s*abc123$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*username: 'mykey'$/) }
        end

        context "with configuration => {'credentials' => [{'id' => 'key1', 'type' => 'private_key', 'key' => 'def456'}, {'id' => 'key2', 'type' => 'private_key', 'secret' => 'ghi789'}]}" do
          let(:params) { {
              'configuration' => [
                                   {'id' => 'key1', 'type' => 'private_key', 'key' => "def456\n"},
                                   {'id' => 'key2', 'type' => 'private_key', 'key' => "ghi789\n"}
                                 ]
          } }

          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*id: 'key1'$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*privateKey: \|\n\s*def456$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*username: 'key1'$/) }

          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*id: 'key2'$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*privateKey: \|\n\s*ghi789$/) }
          it { is_expected.to contain_file('ssh-credentials configuration').with_content(/^\s*username: 'key2'$/) }
        end
      end

      context "with title aws-credentials" do
        let(:title) { 'aws-credentials' }

        context "with configuration => {'id' => 'awscred', 'type' => 'aws', 'access_key' => 'mykey', 'secret_key' => 'mysecret'}" do
          let(:params) { {
              'configuration' => {'id' => 'awscred', 'type' => 'aws', 'access_key' => 'mykey', 'secret_key' => 'mysecret'}
          } }

          it { is_expected.to contain_file('aws-credentials configuration').with(
            'ensure'  => 'file',
            'path'    => '/var/lib/jenkins/casc_config/aws-credentials.yaml',
            'owner'   => 'jenkins',
            'group'   => 'jenkins'
          ) }

          it { is_expected.to contain_file('aws-credentials configuration').with_content(/^\s*id: 'awscred'$/) }
          it { is_expected.to contain_file('aws-credentials configuration').with_content(/^\s*accessKey: 'mykey'$/) }
          it { is_expected.to contain_file('aws-credentials configuration').with_content(/^\s*secretKey: 'mysecret'$/) }
        end

        context "with configuration => [{'id' => 'awscred1', 'type' => 'aws', 'access_key' => 'awskey1', 'secret_key' => 'secretkey1'}, {'id' => 'awscred2', 'type' => 'aws', 'access_key' => 'awskey2', 'secret_key' => 'secretkey2'}]" do
          let(:params) { {
              'configuration' => [
                                   {'id' => 'awscred1', 'type' => 'aws', 'access_key' => 'awskey1', 'secret_key' => 'secretkey1'},
                                   {'id' => 'awscred2', 'type' => 'aws', 'access_key' => 'awskey2', 'secret_key' => 'secretkey2'}
                                 ]
          } }

          it { is_expected.to contain_file('aws-credentials configuration').with_content(/^\s*id: 'awscred1'$/) }
          it { is_expected.to contain_file('aws-credentials configuration').with_content(/^\s*accessKey: 'awskey1'$/) }
          it { is_expected.to contain_file('aws-credentials configuration').with_content(/^\s*secretKey: 'secretkey1'$/) }

          it { is_expected.to contain_file('aws-credentials configuration').with_content(/^\s*id: 'awscred2'$/) }
          it { is_expected.to contain_file('aws-credentials configuration').with_content(/^\s*accessKey: 'awskey2'$/) }
          it { is_expected.to contain_file('aws-credentials configuration').with_content(/^\s*secretKey: 'secretkey2'$/) }
        end
      end

      context "with title git" do
        let(:title) { 'git' }

        context "with configuration => {'user_name' => 'foobar', 'user_email' => 'myuser@example.com'}" do
          let(:params) { {
              'configuration' => {'user_name' => 'foobar', 'user_email' => 'myuser@example.com'}
          } }

          it { is_expected.to contain_file('git configuration').with(
            'ensure'  => 'file',
            'path'    => '/var/lib/jenkins/casc_config/git.yaml',
            'owner'   => 'jenkins',
            'group'   => 'jenkins'
          ) }

          it { is_expected.to contain_file('git configuration').with_content(/^\s*globalConfigName: 'foobar'$/) }
          it { is_expected.to contain_file('git configuration').with_content(/^\s*globalConfigEmail: 'myuser@example.com'$/) }
        end

        context "with configuration => {'user_name' => 'testuser', 'user_email' => 'testuser@foobar.com'}" do
          let(:params) { {
              'configuration' => {'user_name' => 'testuser', 'user_email' => 'testuser@foobar.com'}
          } }

          it { is_expected.to contain_file('git configuration').with_content(/^\s*globalConfigName: 'testuser'$/) }
          it { is_expected.to contain_file('git configuration').with_content(/^\s*globalConfigEmail: 'testuser@foobar.com'$/) }
        end
      end

      context "with title workflow-cps-global-lib" do
        let(:title) { 'workflow-cps-global-lib' }

        context "with configuration => {'git_url' => 'git@example.com:org/repo.git', 'git_ref' => 'main', 'credential_id' => 'mygitcred'}" do
          let(:params) { {
              'configuration' => {
                                   'git_url'       => 'git@example.com:org/repo.git',
                                   'git_ref'       => 'main',
                                   'credential_id' => 'mygitcred'
                                 }
          } }

          it { is_expected.to contain_file('workflow-cps-global-lib configuration').with(
            'ensure'  => 'file',
            'path'    => '/var/lib/jenkins/casc_config/workflow-cps-global-lib.yaml',
            'owner'   => 'jenkins',
            'group'   => 'jenkins'
          ) }

          it { is_expected.to contain_file('workflow-cps-global-lib configuration').with_content(/^\s*remote: 'git@example.com:org\/repo.git'$/) }
          it { is_expected.to contain_file('workflow-cps-global-lib configuration').with_content(/^\s*defaultVersion: 'main'$/) }
          it { is_expected.to contain_file('workflow-cps-global-lib configuration').with_content(/^\s*credentialsId: 'mygitcred'$/) }
        end

        context "with configuration => [{'git_url' => 'git@foo.com:bar/baz.git', 'git_ref' => 'refs/heads/develop', 'credential_id' => 'gitkey'}, {'git_url' => 'git@example.com:org/repo.git', 'git_ref' => 'feature/magic', 'credential_id' => 'mygitcred'}]" do
          let(:params) { {
              'configuration' => [{
                                   'git_url'       => 'git@foo.com:bar/baz.git',
                                   'git_ref'       => 'refs/heads/develop',
                                   'credential_id' => 'gitkey'
                                 },
                                 {
                                   'git_url'       => 'git@example.com:org/repo.git',
                                   'git_ref'       => 'feature/magic',
                                   'credential_id' => 'mygitcred'
                                 }]
          } }

          it { is_expected.to contain_file('workflow-cps-global-lib configuration').with_content(/^\s*remote: 'git@foo.com:bar\/baz.git'$/) }
          it { is_expected.to contain_file('workflow-cps-global-lib configuration').with_content(/^\s*defaultVersion: 'heads\/develop'$/) }
          it { is_expected.to contain_file('workflow-cps-global-lib configuration').with_content(/^\s*credentialsId: 'gitkey'$/) }
          it { is_expected.to contain_file('workflow-cps-global-lib configuration').with_content(/^\s*remote: 'git@example.com:org\/repo.git'$/) }
          it { is_expected.to contain_file('workflow-cps-global-lib configuration').with_content(/^\s*defaultVersion: 'feature\/magic'$/) }
          it { is_expected.to contain_file('workflow-cps-global-lib configuration').with_content(/^\s*credentialsId: 'mygitcred'$/) }
        end
      end

      context "with title job-dsl" do
        let(:title) { 'job-dsl' }

        context "with configuration => { 'name' => 'myrepo', 'git_url' => 'git@example.com:org/myrepo.git', 'git_ref' => 'refs/heads/main', 'credential_id' => 'mygitcred', 'auto_build' => true, 'keep_builds' => 5 }" do
          let(:params) { {
              'configuration' => {
                                   'name'          => 'myrepo',
                                   'git_url'       => 'git@example.com:org/myrepo.git',
                                   'git_ref'       => 'refs/heads/main',
                                   'credential_id' => 'mygitcred',
                                   'auto_build'    => true,
                                   'keep_builds'   => 5
                                 }
          } }

          it { is_expected.to contain_file('job-dsl configuration').with(
            'ensure'  => 'file',
            'path'    => '/var/lib/jenkins/casc_config/job-dsl.yaml',
            'owner'   => 'jenkins',
            'group'   => 'jenkins'
          ) }

          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*pipelineJob\('myrepo'\)/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*url\('git@example.com:org\/myrepo.git'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*scriptPath\('Jenkinsfile'\)$/) }
          it { is_expected.to_not contain_file('job-dsl configuration').with_content(/^\s*githubProjectUrl/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*branch\('refs\/heads\/main'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*credentials\('mygitcred'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*githubPush\(\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*numToKeepStr\('5'\)$/) }
        end

        context "with configuration => [{ 'name' => 'baz', 'git_url' => 'git@github.com:bar/baz.git', 'git_ref' => 'refs/heads/develop', 'jenkinsfile_path' => 'Jenkinsfile.baz', 'credential_id' => 'gitkey', keep_builds => 10 }, { 'name' => 'repo', 'git_url' => 'git@example.com:org/repo.git', 'git_ref' => 'main', 'jenkinsfile_path' => 'pipelines/Jenkinsfile.repo', 'credential_id' => 'mygitcred', keep_builds => '2' }]" do
          let(:params) { {
              'configuration' => [{
                                   'name'             => 'baz',
                                   'git_url'          => 'git@github.com:bar/baz.git',
                                   'git_ref'          => 'refs/heads/develop',
                                   'jenkinsfile_path' => 'Jenkinsfile.baz',
                                   'credential_id'    => 'gitkey',
                                   'keep_builds'      => 10
                                 },
                                 {
                                   'name'             => 'repo',
                                   'git_url'          => 'git@example.com:org/repo.git',
                                   'git_ref'          => 'main',
                                   'jenkinsfile_path' => 'pipelines/Jenkinsfile.repo',
                                   'credential_id'    => 'mygitcred',
                                   'keep_builds'      => 2
                                 }]
          } }

          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*pipelineJob\('baz'\)/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*url\('git@github.com:bar\/baz.git'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*scriptPath\('Jenkinsfile.baz'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*githubProjectUrl\('https:\/\/github.com\/bar\/baz'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*branch\('refs\/heads\/develop'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*credentials\('gitkey'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*numToKeepStr\('10'\)$/) }

          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*pipelineJob\('repo'\)/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*url\('git@example.com:org\/repo.git'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*scriptPath\('pipelines\/Jenkinsfile.repo'\)$/) }
          it { is_expected.to_not contain_file('job-dsl configuration').with_content(/^\s*githubProjectUrl\('https:\/\/github.com\/org\/repo'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*branch\('main'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*credentials\('mygitcred'\)$/) }
          it { is_expected.to contain_file('job-dsl configuration').with_content(/^\s*numToKeepStr\('2'\)$/) }

          it { is_expected.to_not contain_file('job-dsl configuration').with_content(/^\s*githubPush\(\)$/) }
        end
      end
    end
  end
end
