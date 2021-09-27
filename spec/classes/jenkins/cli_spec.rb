require 'spec_helper'

describe 'profiles::jenkins::cli' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with admin_user => john and admin_password => doe" do
        let(:params) { {
          'user' => 'john',
          'password' => 'doe'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('publiq-jenkins') }
        it { is_expected.to contain_profiles__apt__update('publiq-jenkins') }

        it { is_expected.to contain_package('jenkins-cli').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_package('jenkins-cli').that_requires('Profiles::Apt::Update[publiq-jenkins]') }

        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with(
          'ensure' => 'file',
          'mode'   => '0644'
        ) }

        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/JENKINS_USER=john/) }
        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/JENKINS_PASSWORD=doe/) }
        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/SERVER_URL=http:\/\/localhost:8080/) }

        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').that_requires('Package[jenkins-cli]') }

        context "with version => 1.2.3, server_url => http://remote:5555/" do
          let(:params) {
            super().merge({
              'version'    => '1.2.3',
              'server_url' => 'http://remote:5555/'
            })
          }

          it { is_expected.to contain_package('jenkins-cli').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/SERVER_URL=http:\/\/remote:5555/) }
        end
      end

      context "with admin_user => jane and admin_password => roe" do
        let(:params) { {
          'user' => 'jane',
          'password' => 'roe'
        } }

        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/JENKINS_USER=jane/) }
        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/JENKINS_PASSWORD=roe/) }
      end

      context "without parameters it uses hieradata from profiles::jenkins::controller" do
        let(:hiera_config) { 'spec/support/hiera/hiera.yaml' }
        let(:params) { {} }

        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/JENKINS_USER=foo/) }
        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/JENKINS_PASSWORD=bar/) }
      end

      context "without parameters it defaults to empty strings for user and password without hieradata" do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }
        let(:params) { {} }

        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/JENKINS_USER=\n/) }
        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/JENKINS_PASSWORD=\n/) }
      end
    end
  end
end
