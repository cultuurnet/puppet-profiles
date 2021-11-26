require 'spec_helper'

describe 'profiles::jenkins::controller::install' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::jenkins::controller::install').with(
          'version'        => 'latest'
        ) }

        it { is_expected.to contain_group('jenkins') }
        it { is_expected.to contain_user('jenkins') }

        it { is_expected.to contain_profiles__apt__update('publiq-jenkins') }

        it { is_expected.to contain_package('jenkins').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('casc_config').with(
          'ensure' => 'directory',
          'path'   => '/var/lib/jenkins/casc_config',
          'owner'  => 'jenkins',
          'group'  => 'jenkins'
        ) }

        it { is_expected.to contain_shellvar('JAVA_ARGS').with(
          'ensure'   => 'present',
          'variable' => 'JAVA_ARGS',
          'target'   => '/etc/default/jenkins',
          'value'    => '-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/casc_config'
        ) }

        it { is_expected.to contain_file('casc_config').that_requires('User[jenkins]') }
        it { is_expected.to contain_file('casc_config').that_requires('Package[jenkins]') }
        it { is_expected.to contain_shellvar('JAVA_ARGS').that_requires('File[casc_config]') }
        it { is_expected.to contain_package('jenkins').that_requires('User[jenkins]') }
        it { is_expected.to contain_package('jenkins').that_requires('Profiles::Apt::Update[publiq-jenkins]') }
      end

      context "with version => 1.2.3" do
        let(:params) { {
          'version'        => '1.2.3'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('jenkins').with(
          'ensure' => '1.2.3'
        ) }
      end
    end
  end
end
