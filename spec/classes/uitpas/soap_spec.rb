describe 'profiles::uitpas::soap' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'in the production environment' do
        let(:environment) { 'production' }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with default parameters" do
            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::soap').with(
              'deployment_enabled' => true,
              'repository'         => 'uitpas-soap',
              'version'            => 'latest'
            ) }

            it { is_expected.to contain_class('profiles::java') }

            it { is_expected.to contain_package('uitpas-soap').with(
              'ensure' => 'latest'
            ) }

            it { is_expected.to contain_file('/etc/systemd/system/uitpas-soap.service').with(
              'content' => /User=glassfish/
            ) }

            it { is_expected.to contain_exec('uitpas-soap-systemd-reload').with(
              'command'     => '/bin/systemctl daemon-reload',
              'refreshonly' => true
            ) }

            it { is_expected.to contain_service('uitpas-soap').with(
              'ensure'     => 'running',
              'enable'     => true,
              'hasstatus'  => true,
              'hasrestart' => true
            ) }

            it { is_expected.to contain_package('uitpas-soap').that_requires('Apt::Source[uitpas-soap]') }
            it { is_expected.to contain_package('uitpas-soap').that_notifies('Service[uitpas-soap]') }
            it { is_expected.to contain_service('uitpas-soap').that_requires('Class[profiles::java]') }
            it { is_expected.to contain_service('uitpas-soap').that_requires('Package[uitpas-soap]') }
            it { is_expected.to contain_service('uitpas-soap').that_requires('File[/etc/systemd/system/uitpas-soap.service]') }
            it { is_expected.to contain_file('/etc/systemd/system/uitpas-soap.service').that_notifies('Exec[uitpas-soap-systemd-reload]') }
            it { is_expected.to contain_file('/etc/systemd/system/uitpas-soap.service').that_notifies('Service[uitpas-soap]') }
          end

          context "with deployment_enabled => false, repository => uitpas-soap and version => 1.2.3" do
            let(:params) { {
              'deployment_enabled' => false,
              'repository'         => 'uitpas-soap',
              'version'            => '1.2.3'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::soap').with(
              'deployment_enabled' => false,
              'repository'         => 'uitpas-soap',
              'version'            => '1.2.3'
            ) }

            it { is_expected.to contain_class('profiles::java') }

            it { is_expected.to contain_package('uitpas-soap') }

            it { is_expected.to contain_service('uitpas-soap').with(
              'ensure'     => 'stopped',
              'enable'     => false,
              'hasstatus'  => true,
              'hasrestart' => true
            ) }

            it { is_expected.to contain_service('uitpas-soap').that_requires('Class[profiles::java]') }
            it { is_expected.to contain_service('uitpas-soap').that_requires('Package[uitpas-soap]') }
          end

          context "with deployment_enabled => true, repository => uitpas-soap and version => 2.0.0" do
            let(:params) { {
              'deployment_enabled' => true,
              'repository'         => 'uitpas-soap',
              'version'            => '2.0.0'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::soap').with(
              'deployment_enabled' => true,
              'repository'         => 'uitpas-soap',
              'version'            => '2.0.0'
            ) }

            it { is_expected.to contain_package('uitpas-soap').with(
              'ensure' => '2.0.0'
            ) }

            it { is_expected.to contain_service('uitpas-soap').with(
              'ensure' => 'running',
              'enable' => true
            ) }

            it { is_expected.to contain_package('uitpas-soap').that_requires('Apt::Source[uitpas-soap]') }
          end
        end
      end

      context 'in the testing environment' do
        let(:environment) { 'testing' }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with deployment_enabled => false" do
            let(:params) { {
              'deployment_enabled' => false
            } }

            it { is_expected.to contain_service('uitpas-soap').with(
              'ensure' => 'stopped',
              'enable' => false
            ) }

            it { is_expected.to contain_package('uitpas-soap') }
          end
        end
      end
    end
  end
end