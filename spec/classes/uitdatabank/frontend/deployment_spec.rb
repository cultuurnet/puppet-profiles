describe 'profiles::uitdatabank::frontend::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with config_source => appconfig/uitdatabank/udb3-frontend/env' do
          let(:params) { {
            'config_source' => 'appconfig/uitdatabank/udb3-frontend/env'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment').with(
            'config_source'   => 'appconfig/uitdatabank/udb3-frontend/env',
            'type'            => 'instance',
            'service_address' => '127.0.0.1',
            'service_port'    => 4000
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-frontend').with(
            'ensure' => 'directory'
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-frontend/env').with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0640',
            'content' => "KEY=value\n"
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment::instance').with(
            'service_address' => '127.0.0.1',
            'service_port'    => 4000
          ) }

          it { is_expected.not_to contain_class('profiles::uitdatabank::frontend::deployment::container') }

          it { is_expected.to contain_file('/etc/uitdatabank-frontend/env').that_notifies('Class[profiles::uitdatabank::frontend::deployment::instance]') }
        end

        context 'with type => container, config_source => appconfig/uitdatabank/udb3-frontend/myenv, service_address => 0.0.0.0 and service_port => 6000' do
          let(:pre_condition) { 'function ecr_docker_image_version_tag($parameter1, $parameter2) { return "2026.10.07.000000" }' }

          let(:params) { {
            'type'            => 'container',
            'config_source'   => 'appconfig/uitdatabank/udb3-frontend/myenv',
            'service_address' => '0.0.0.0',
            'service_port'    => 6000
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file('/etc/uitdatabank-frontend/env').with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0640',
            'content' => "MYKEY=myvalue\n"
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment::container').with(
            'service_port' => 6000
          ) }

          it { is_expected.not_to contain_class('profiles::uitdatabank::frontend::deployment::instance') }

          it { is_expected.to contain_file('/etc/uitdatabank-frontend/env').that_notifies('Class[profiles::uitdatabank::frontend::deployment::container]') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
