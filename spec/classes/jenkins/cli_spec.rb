require 'spec_helper'

describe 'profiles::jenkins::cli' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without params" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::jenkins::cli').with(
          'manage_credentials' => false,
          'version'            => 'latest',
          'user'               => '',
          'password'           => '',
          'controller_url'     => 'http://localhost:8080/'
        ) }

        it { is_expected.to_not contain_class('profiles::jenkins::cli::credentials') }

        it { is_expected.to contain_apt__source('publiq-jenkins') }
        it { is_expected.to contain_profiles__apt__update('publiq-jenkins') }
        it { is_expected.to contain_class('profiles::java') }

        it { is_expected.to contain_package('jenkins-cli').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('jenkins-cli_configdir').with(
          'ensure' => 'directory',
          'path'   => '/etc/jenkins-cli',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('jenkins-cli_config').with(
          'ensure' => 'file',
          'path'   => '/etc/jenkins-cli/cli.conf',
          'mode'   => '0644'
        ) }

        it { is_expected.to contain_shellvar('CONTROLLER_URL').with(
          'ensure'   => 'present',
          'variable' => 'CONTROLLER_URL',
          'target'   => '/etc/jenkins-cli/cli.conf',
          'value'    => 'http://localhost:8080/'
        ) }

        it { is_expected.to contain_package('jenkins-cli').that_requires('Profiles::Apt::Update[publiq-jenkins]') }
        it { is_expected.to contain_package('jenkins-cli').that_requires('Class[profiles::java]') }
        it { is_expected.to contain_file('jenkins-cli_configdir').that_requires('Package[jenkins-cli]') }
        it { is_expected.to contain_file('jenkins-cli_config').that_requires('Package[jenkins-cli]') }
        it { is_expected.to contain_shellvar('CONTROLLER_URL').that_requires('File[jenkins-cli_config]') }
      end

      context "with version => 1.2.3, controller_url => http://remote:5555/, manage_credentials => true, user => john and password => doe" do
        let(:params) { {
            'manage_credentials' => true,
            'version'            => '1.2.3',
            'user'               => 'john',
            'password'           => 'doe',
            'controller_url'     => 'http://remote:5555/'
          } }

        it { is_expected.to contain_package('jenkins-cli').with(
          'ensure' => '1.2.3'
        ) }

        it { is_expected.to contain_class('profiles::jenkins::cli::credentials').with(
          'user'     => 'john',
          'password' => 'doe'
        ) }

        it { is_expected.to contain_shellvar('CONTROLLER_URL').with(
          'ensure'   => 'present',
          'variable' => 'CONTROLLER_URL',
          'target'   => '/etc/jenkins-cli/cli.conf',
          'value'    => 'http://remote:5555/'
        ) }

        it { is_expected.to contain_class('profiles::jenkins::cli::credentials').that_requires('File[jenkins-cli_config]') }
      end

      context "manage_credentials => true, user => jane and password => roe" do
        let(:params) { {
          'manage_credentials' => true,
          'user'               => 'jane',
          'password'           => 'roe'
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
          'manage_credentials' => false,
          'user'               => 'foo',
          'password'           => 'bar',
          'version'            => 'latest',
          'controller_url'     => 'https://foobar.com/'
        ) }

        it { is_expected.to_not contain_class('profiles::jenkins::cli::credentials') }

        it { is_expected.to contain_shellvar('CONTROLLER_URL').with(
          'ensure'   => 'present',
          'variable' => 'CONTROLLER_URL',
          'target'   => '/etc/jenkins-cli/cli.conf',
          'value'    => 'https://foobar.com/'
        ) }
      end
    end
  end
end
