describe 'profiles::uitdatabank::frontend::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => /foo' do
        let(:params) { {
          'config_source' => '/foo',
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment').with(
          'config_source'   => '/foo',
          'version'         => 'latest',
          'repository'      => 'uitdatabank-frontend',
          'service_status'  => 'running',
          'service_address' => '127.0.0.1',
          'service_port'    => '4000',
          'puppetdb_url'    => nil
        ) }

        it { is_expected.to contain_apt__source('uitdatabank-frontend') }

        it { is_expected.to contain_package('uitdatabank-frontend').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('uitdatabank-frontend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/udb3-frontend/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitdatabank-frontend-service-defaults').with(
          'ensure'  => 'file',
          'path'    => '/etc/default/uitdatabank-frontend',
          'content' => "NEXT_HOST=127.0.0.1\nNEXT_PORT=4000\nNEXT_TELEMETRY_DISABLED=1"
        ) }

        it { is_expected.to contain_service('uitdatabank-frontend').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_package('uitdatabank-frontend').that_notifies('Service[uitdatabank-frontend]') }
        it { is_expected.to contain_package('uitdatabank-frontend').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::frontend::deployment]') }
        it { is_expected.to contain_package('uitdatabank-frontend').that_requires('Apt::Source[uitdatabank-frontend]') }
        it { is_expected.to contain_file('uitdatabank-frontend-config').that_requires('Package[uitdatabank-frontend]') }
        it { is_expected.to contain_file('uitdatabank-frontend-service-defaults').that_requires('Package[uitdatabank-frontend]') }
        it { is_expected.to contain_file('uitdatabank-frontend-config').that_notifies('Service[uitdatabank-frontend]') }
        it { is_expected.to contain_file('uitdatabank-frontend-service-defaults').that_notifies('Service[uitdatabank-frontend]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::frontend::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::frontend::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context 'with repository uitdatabank-frontend-alternative defined' do
        let(:pre_condition) { '@apt::source { "uitdatabank-frontend-alternative": location => "http://localhost", release => "focal", repos => "main" }' }

        context 'with config_source => /bar, version => 1.2.3, repository => uitdatabank-frontend-alternative, service_status => stopped, service_address => 0.0.0.0 and service_port => 6000 ' do
          let(:params) { {
            'config_source'   => '/bar',
            'version'         => '1.2.3',
            'repository'      => 'uitdatabank-frontend-alternative',
            'service_status'  => 'stopped',
            'service_address' => '0.0.0.0',
            'service_port'    => 6000
          } }

          it { is_expected.to contain_apt__source('uitdatabank-frontend-alternative') }

          it { is_expected.to contain_package('uitdatabank-frontend').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_file('uitdatabank-frontend-service-defaults').with(
            'ensure'  => 'file',
            'path'    => '/etc/default/uitdatabank-frontend',
            'content' => "NEXT_HOST=0.0.0.0\nNEXT_PORT=6000\nNEXT_TELEMETRY_DISABLED=1"
          ) }

          it { is_expected.to contain_service('uitdatabank-frontend').with(
            'ensure'    => 'stopped',
            'enable'    => false,
            'hasstatus' => true
          ) }

          it { is_expected.to contain_package('uitdatabank-frontend').that_requires('Apt::Source[uitdatabank-frontend-alternative]') }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
