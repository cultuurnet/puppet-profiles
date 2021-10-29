require 'spec_helper'

describe 'profiles::jenkins::cli' do
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

        it { is_expected.to contain_apt__source('publiq-jenkins') }
        it { is_expected.to contain_profiles__apt__update('publiq-jenkins') }
        it { is_expected.to contain_class('profiles::java') }

        it { is_expected.to contain_package('jenkins-cli').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_package('jenkins-cli').that_requires('Profiles::Apt::Update[publiq-jenkins]') }
        it { is_expected.to contain_package('jenkins-cli').that_requires('Class[profiles::java]') }

        it { is_expected.to contain_file('jenkins-cli_config').with(
          'ensure' => 'file',
          'path'   => '/etc/jenkins-cli/cli.conf',
          'mode'   => '0644'
        ) }

        it { is_expected.to contain_file('jenkins-cli_config').that_requires('Package[jenkins-cli]') }

        it { is_expected.to contain_class('profiles::jenkins::cli::credentials').with(
          'user'     => 'john',
          'password' => 'doe'
        ) }

        it { is_expected.to contain_shellvar('JENKINS_URL').with(
          'ensure'   => 'present',
          'variable' => 'JENKINS_URL',
          'target'   => '/etc/jenkins-cli/cli.conf',
          'value'    => 'http://localhost:8080/'
        ) }

        it { is_expected.to contain_class('profiles::jenkins::cli::credentials').that_requires('File[jenkins-cli_config]') }
        it { is_expected.to contain_shellvar('JENKINS_URL').that_requires('File[jenkins-cli_config]') }

        context "with version => 1.2.3, server_url => http://remote:5555/ and manage_credentials => false" do
          let(:params) {
            super().merge({
              'manage_credentials' => false,
              'version'            => '1.2.3',
              'server_url'         => 'http://remote:5555/'
            })
          }

          it { is_expected.to contain_package('jenkins-cli').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to_not contain_class('profiles::jenkins::cli::credentials') }

          it { is_expected.to contain_shellvar('JENKINS_URL').with(
            'ensure'   => 'present',
            'variable' => 'JENKINS_URL',
            'target'   => '/etc/jenkins-cli/cli.conf',
            'value'    => 'http://remote:5555/'
          ) }
        end
      end

      context "with user => jane and password => roe" do
        let(:params) { {
          'user' => 'jane',
          'password' => 'roe'
        } }

        it { is_expected.to contain_class('profiles::jenkins::cli::credentials').with(
          'user'     => 'jane',
          'password' => 'roe'
        ) }
      end

      context "without parameters it uses hieradata from profiles::jenkins::controller" do
        let(:hiera_config) { 'spec/support/hiera/hiera.yaml' }
        let(:params) { {} }

        it { is_expected.to contain_class('profiles::jenkins::cli').with(
          'manage_credentials' => true,
          'user'               => 'foo',
          'password'           => 'bar',
          'version'            => 'latest',
          'server_url'         => 'https://foobar.com/baz/'
        ) }

        it { is_expected.to contain_class('profiles::jenkins::cli::credentials').with(
          'user'     => 'foo',
          'password' => 'bar'
        ) }

        it { is_expected.to contain_shellvar('JENKINS_URL').with(
          'ensure'   => 'present',
          'variable' => 'JENKINS_URL',
          'target'   => '/etc/jenkins-cli/cli.conf',
          'value'    => 'https://foobar.com/baz/'
        ) }
      end

      context "without parameters and without hieradata" do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }
        let(:params) { {} }

        it { is_expected.to contain_class('profiles::jenkins::cli').with(
          'manage_credentials' => true,
          'user'               => '',
          'password'           => '',
          'version'            => 'latest',
          'server_url'         => 'http://localhost:8080/'
        ) }

        it { is_expected.to contain_class('profiles::jenkins::cli::credentials').with(
          'user'     => '',
          'password' => ''
        ) }

        it { is_expected.to contain_shellvar('JENKINS_URL').with(
          'ensure'   => 'present',
          'variable' => 'JENKINS_URL',
          'target'   => '/etc/jenkins-cli/cli.conf',
          'value'    => 'http://localhost:8080/'
        ) }
      end
    end
  end
end
