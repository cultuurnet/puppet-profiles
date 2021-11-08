require 'spec_helper'

describe 'profiles::jenkins::node' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with user => john, password => doe and url => 'https://jenkins.example.com/'" do
        let(:params) { {
          'user'           => 'john',
          'password'       => 'doe',
          'controller_url' => 'https://jenkins.example.com/'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::jenkins::node').with(
          'user'           => 'john',
          'password'       => 'doe',
          'version'        => 'latest',
          'controller_url' => 'https://jenkins.example.com/',
          'executors'      => 1,
          'labels'         => []
        ) }

        it { is_expected.to contain_apt__source('publiq-jenkins') }
        it { is_expected.to contain_profiles__apt__update('publiq-jenkins') }
        it { is_expected.to contain_class('profiles::java') }
        it { is_expected.to contain_group('jenkins') }
        it { is_expected.to contain_user('jenkins') }

        it { is_expected.to contain_package('jenkins-swarm-client').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('jenkins-swarm-client_fsroot').with(
          'ensure'  => 'directory',
          'owner'   => 'jenkins',
          'group'   => 'jenkins',
          'path'    => '/var/lib/jenkins-swarm-client',
          'mode'    => '0755'
        ) }

        it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').with(
          'ensure'  => 'file',
          'owner'   => 'jenkins',
          'group'   => 'jenkins',
          'path'    => '/etc/jenkins-swarm-client/password',
          'mode'    => '0600',
          'content' => "doe"
        ) }

        it { is_expected.to contain_file('jenkins-swarm-client_node-labels').with(
          'ensure'  => 'file',
          'owner'   => 'jenkins',
          'group'   => 'jenkins',
          'path'    => '/etc/jenkins-swarm-client/node-labels.conf',
          'mode'    => '0644',
          'content' => ''
        ) }

        it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with(
          'ensure'  => 'file',
          'path'    => '/etc/default/jenkins-swarm-client',
          'mode'    => '0644'
        ) }

        it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^JENKINS_USER=john$/) }
        it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^CONTROLLER_URL=https:\/\/jenkins\.example\.com\/$/) }
        it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^BUILD_EXECUTORS=1$/) }

        it { is_expected.to contain_service('jenkins-swarm-client').with(
          'ensure' => 'running',
          'enable' => true
        ) }

        it { is_expected.to contain_package('jenkins-swarm-client').that_requires('Profiles::Apt::Update[publiq-jenkins]') }
        it { is_expected.to contain_package('jenkins-swarm-client').that_notifies('Service[jenkins-swarm-client]') }
        it { is_expected.to contain_file('jenkins-swarm-client_fsroot').that_requires('User[jenkins]') }
        it { is_expected.to contain_file('jenkins-swarm-client_fsroot').that_requires('Group[jenkins]') }
        it { is_expected.to contain_file('jenkins-swarm-client_fsroot').that_notifies('Service[jenkins-swarm-client]') }
        it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').that_requires('User[jenkins]') }
        it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').that_requires('Group[jenkins]') }
        it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').that_requires('Package[jenkins-swarm-client]') }
        it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').that_notifies('Service[jenkins-swarm-client]') }
        it { is_expected.to contain_file('jenkins-swarm-client_node-labels').that_requires('User[jenkins]') }
        it { is_expected.to contain_file('jenkins-swarm-client_node-labels').that_requires('Group[jenkins]') }
        it { is_expected.to contain_file('jenkins-swarm-client_node-labels').that_requires('Package[jenkins-swarm-client]') }
        it { is_expected.to contain_file('jenkins-swarm-client_node-labels').that_notifies('Service[jenkins-swarm-client]') }
        it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').that_requires('Package[jenkins-swarm-client]') }
        it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').that_notifies('Service[jenkins-swarm-client]') }
        it { is_expected.to contain_service('jenkins-swarm-client').that_requires('User[jenkins]') }
        it { is_expected.to contain_service('jenkins-swarm-client').that_requires('Group[jenkins]') }
        it { is_expected.to contain_service('jenkins-swarm-client').that_requires('Class[profiles::java]') }
      end

      context "with user => jane, password => roe, controller_url => 'http://localhost:5555/' and executors => 4" do
        let(:params) { {
          'user'           => 'jane',
          'password'       => 'roe',
          'controller_url' => 'http://localhost:5555/',
          'executors'      => 4
        } }

        it { is_expected.to contain_file('jenkins-swarm-client_passwordfile').with(
          'content' => 'roe'
        ) }

        it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^JENKINS_USER=jane$/) }
        it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^CONTROLLER_URL=http:\/\/localhost:5555\/$/) }
        it { is_expected.to contain_file('jenkins-swarm-client_service-defaults').with_content(/^BUILD_EXECUTORS=4$/) }

        context "with labels => foo" do
          let(:params) {
            super().merge({
              'labels' => 'foo'
            })
          }

          it { is_expected.to contain_file('jenkins-swarm-client_node-labels').with(
            'content' => 'foo'
          ) }
        end

        context "with labels => [bar, baz, oomph]" do
          let(:params) {
            super().merge({
              'labels' => ['bar', 'baz', 'oomph']
            })
          }

          it { is_expected.to contain_file('jenkins-swarm-client_node-labels').with(
            'content' => "bar\nbaz\noomph"
          ) }
        end
      end

      context "without parameters it uses hieradata from profiles::jenkins::controller" do
        let(:hiera_config) { 'spec/support/hiera/hiera.yaml' }
        let(:params) { {} }

        it { is_expected.to contain_class('profiles::jenkins::node').with(
          'user'           => 'foo',
          'password'       => 'bar',
          'version'        => 'latest',
          'controller_url' => 'https://foobar.com/',
          'executors'      => 1,
          'labels'         => []
        ) }
      end

      context "without parameters and without hieradata" do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }
        let(:params) { {} }

        it { is_expected.to contain_class('profiles::jenkins::node').with(
          'user'           => '',
          'password'       => '',
          'version'        => 'latest',
          'controller_url' => 'http://localhost:8080/',
          'executors'      => 1,
          'labels'         => []
        ) }
      end
    end
  end
end
