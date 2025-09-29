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

            it { is_expected.to contain_service('uitpas-soap').with(
              'ensure'     => 'running',
              'enable'     => true,
              'hasstatus'  => true,
              'hasrestart' => true,
              'start'      => '/usr/bin/java -jar /opt/uitpas-soap/uitpas-soap.jar'
            ) }

            it { is_expected.to contain_package('uitpas-soap').that_requires('Apt::Source[uitpas-soap]') }
            it { is_expected.to contain_package('uitpas-soap').that_notifies('Service[uitpas-soap]') }
            it { is_expected.to contain_service('uitpas-soap').that_requires('Class[profiles::java]') }
            it { is_expected.to contain_service('uitpas-soap').that_requires('Package[uitpas-soap]') }
          end

          context "with deployment_enabled => false, repository => my-repo and version => 1.2.3" do
            let(:params) { {
              'deployment_enabled' => false,
              'repository'         => 'my-repo',
              'version'            => '1.2.3'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::soap').with(
              'deployment_enabled' => false,
              'repository'         => 'my-repo',
              'version'            => '1.2.3'
            ) }

            it { is_expected.to contain_class('profiles::java') }

            it { is_expected.not_to contain_package('uitpas-soap') }

            it { is_expected.to contain_service('uitpas-soap').with(
              'ensure'     => 'stopped',
              'enable'     => false,
              'hasstatus'  => true,
              'hasrestart' => true,
              'start'      => '/usr/bin/java -jar /opt/uitpas-soap/uitpas-soap.jar'
            ) }

            it { is_expected.to contain_service('uitpas-soap').that_requires('Class[profiles::java]') }
            it { is_expected.to contain_service('uitpas-soap').that_requires('Package[uitpas-soap]') }
          end

          context "with deployment_enabled => true, repository => custom-repo and version => 2.0.0" do
            let(:params) { {
              'deployment_enabled' => true,
              'repository'         => 'custom-repo',
              'version'            => '2.0.0'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::soap').with(
              'deployment_enabled' => true,
              'repository'         => 'custom-repo',
              'version'            => '2.0.0'
            ) }

            it { is_expected.to contain_package('uitpas-soap').with(
              'ensure' => '2.0.0'
            ) }

            it { is_expected.to contain_service('uitpas-soap').with(
              'ensure' => 'running',
              'enable' => true
            ) }

            it { is_expected.to contain_package('uitpas-soap').that_requires('Apt::Source[custom-repo]') }
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

            it { is_expected.not_to contain_package('uitpas-soap') }
          end
        end
      end
    end
  end
end