require 'spec_helper'

describe 'profiles::jenkins::cli::credentials' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with user => john and password => doe" do
        let(:params) { {
          'user' => 'john',
          'password' => 'doe'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_shellvar('JENKINS_USER').with(
          'ensure'   => 'present',
          'variable' => 'JENKINS_USER',
          'target'   => '/etc/jenkins-cli/cli.conf',
          'value'    => 'john'
        ) }

        it { is_expected.to contain_shellvar('JENKINS_PASSWORD').with(
          'ensure'   => 'present',
          'variable' => 'JENKINS_PASSWORD',
          'target'   => '/etc/jenkins-cli/cli.conf',
          'value'    => 'doe'
        ) }
      end

      context "with user => jane and password => roe" do
        let(:params) { {
          'user' => 'jane',
          'password' => 'roe'
        } }

        it { is_expected.to contain_shellvar('JENKINS_USER').with(
          'ensure'   => 'present',
          'variable' => 'JENKINS_USER',
          'target'   => '/etc/jenkins-cli/cli.conf',
          'value'    => 'jane'
        ) }

        it { is_expected.to contain_shellvar('JENKINS_PASSWORD').with(
          'ensure'   => 'present',
          'variable' => 'JENKINS_PASSWORD',
          'target'   => '/etc/jenkins-cli/cli.conf',
          'value'    => 'roe'
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'user'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'password'/) }
      end
    end
  end
end
