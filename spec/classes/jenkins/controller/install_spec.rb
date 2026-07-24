describe 'profiles::jenkins::controller::install' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::jenkins::controller::install').with(
          'version'                 => 'latest',
          'session_timeout_minutes' => 480
        ) }

        it { is_expected.to contain_group('jenkins') }
        it { is_expected.to contain_user('jenkins') }

        it { is_expected.to contain_apt__source('publiq-jenkins') }

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
          'value'    => '-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/casc_config -Dhudson.cli.CLIAction.ACCEPT_URL_FROM_REQUEST=true'
        ) }

        it { is_expected.to contain_shellvar('JENKINS_ARGS').with(
          'ensure'   => 'present',
          'variable' => 'JENKINS_ARGS',
          'target'   => '/etc/default/jenkins',
          'value'    => '--sessionTimeout=480 --sessionEviction=28800'
        ) }

        it { is_expected.to contain_systemd__dropin_file('override.conf').with(
          'unit'    => 'jenkins.service',
          'content' => "[Service]\nEnvironment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/casc_config -Dhudson.cli.CLIAction.ACCEPT_URL_FROM_REQUEST=true\"\nEnvironment=\"JENKINS_ARGS=--sessionTimeout=480 --sessionEviction=28800\""
        ) }

        it { is_expected.to contain_file('casc_config').that_requires('User[jenkins]') }
        it { is_expected.to contain_file('casc_config').that_requires('Package[jenkins]') }
        it { is_expected.to contain_shellvar('JAVA_ARGS').that_requires('File[casc_config]') }
        it { is_expected.to contain_shellvar('JENKINS_ARGS').that_requires('File[casc_config]') }
        it { is_expected.to contain_package('jenkins').that_requires('User[jenkins]') }
        it { is_expected.to contain_package('jenkins').that_requires('Apt::Source[publiq-jenkins]') }
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

      context "with session_timeout_minutes => 120" do
        let(:params) { {
          'session_timeout_minutes' => 120
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_shellvar('JENKINS_ARGS').with(
          'value' => '--sessionTimeout=120 --sessionEviction=7200'
        ) }
      end
    end
  end
end
