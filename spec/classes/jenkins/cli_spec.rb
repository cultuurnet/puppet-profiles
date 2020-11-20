require 'spec_helper'

describe 'profiles::jenkins::cli' do
  context "with admin_user => john and admin_password => doe" do
    let(:params) { {
      'user' => 'john',
      'password' => 'doe'
    } }

    include_examples 'operating system support', 'profiles::jenkins::cli'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

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

        context "with version => 1.2.3, server_url => http://remote:5555/" do
          let (:params) {
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
    end
  end

  context "with admin_user => jane and admin_password => roe" do
    let(:params) { {
      'user' => 'jane',
      'password' => 'roe'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/JENKINS_USER=jane/) }
        it { is_expected.to contain_file('/etc/jenkins-cli/cli.conf').with_content(/JENKINS_PASSWORD=roe/) }
      end
    end
  end

  context "without parameters" do
    let(:params) { {} }

    it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'user'/) }
    it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'password'/) }
  end
end
