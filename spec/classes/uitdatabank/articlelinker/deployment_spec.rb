describe 'profiles::uitdatabank::articlelinker::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => appconfig/uitdatabank/uit-articlelinker/config.json' do
        let(:params) { {
          'config_source' => 'appconfig/uitdatabank/uit-articlelinker/config.json',
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::articlelinker::deployment').with(
            'config_source'   => 'appconfig/uitdatabank/uit-articlelinker/config.json',
            'version'         => 'latest',
            'repository'      => 'uitdatabank-articlelinker',
            'service_status'  => 'running',
            'service_address' => '127.0.0.1',
            'service_port'    => '5000',
            'puppetdb_url'    => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_apt__source('uitdatabank-articlelinker') }

          it { is_expected.to contain_package('uitdatabank-articlelinker').with(
            'ensure' => 'latest'
          ) }

          it { is_expected.to contain_file('uitdatabank-articlelinker-config').with(
            'ensure'  => 'file',
            'path'    => '/var/www/uit-articlelinker/config.json',
            'content' => "articlelinker config\n",
            'owner'   => 'www-data',
            'group'   => 'www-data'
          ) }

          it { is_expected.to contain_file('uitdatabank-articlelinker-service-defaults').with(
            'ensure'  => 'file',
            'path'    => '/etc/default/uitdatabank-articlelinker',
            'content' => "HOST=127.0.0.1\nPORT=5000"
          ) }

          it { is_expected.to contain_service('uitdatabank-articlelinker').with(
            'ensure'    => 'running',
            'enable'    => true,
            'hasstatus' => true
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::articlelinker::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_package('uitdatabank-articlelinker').that_notifies('Service[uitdatabank-articlelinker]') }
          it { is_expected.to contain_package('uitdatabank-articlelinker').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::articlelinker::deployment]') }
          it { is_expected.to contain_package('uitdatabank-articlelinker').that_requires('Apt::Source[uitdatabank-articlelinker]') }
          it { is_expected.to contain_file('uitdatabank-articlelinker-config').that_requires('Package[uitdatabank-articlelinker]') }
          it { is_expected.to contain_file('uitdatabank-articlelinker-service-defaults').that_requires('Package[uitdatabank-articlelinker]') }
          it { is_expected.to contain_file('uitdatabank-articlelinker-config').that_notifies('Service[uitdatabank-articlelinker]') }
          it { is_expected.to contain_file('uitdatabank-articlelinker-service-defaults').that_notifies('Service[uitdatabank-articlelinker]') }
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::articlelinker::deployment').with(
            'puppetdb_url' => nil
          ) }
        end
      end

      context 'with config_source => appconfig/uitdatabank/uit-articlelinker/myconfig.json, version => 1.2.3, repository => uitdatabank-articlelinker-alternative, service_status => stopped, service_address => 0.0.0.0 and service_port => 6000 ' do
        let(:params) { {
          'config_source'   => 'appconfig/uitdatabank/uit-articlelinker/myconfig.json',
          'version'         => '1.2.3',
          'repository'      => 'uitdatabank-articlelinker-alternative',
          'service_status'  => 'stopped',
          'service_address' => '0.0.0.0',
          'service_port'    => 6000
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'with repository uitdatabank-articlelinker-alternative defined' do
            let(:pre_condition) { '@apt::source { "uitdatabank-articlelinker-alternative": location => "http://localhost", release => "focal", repos => "main" }' }

            it { is_expected.to contain_apt__source('uitdatabank-articlelinker-alternative') }

            it { is_expected.to contain_package('uitdatabank-articlelinker').with(
              'ensure' => '1.2.3'
            ) }

            it { is_expected.to contain_file('uitdatabank-articlelinker-config').with(
              'content' => "articlelinker myconfig\n"
            ) }

            it { is_expected.to contain_file('uitdatabank-articlelinker-service-defaults').with(
              'ensure'  => 'file',
              'path'    => '/etc/default/uitdatabank-articlelinker',
              'content' => "HOST=0.0.0.0\nPORT=6000"
            ) }

            it { is_expected.to contain_service('uitdatabank-articlelinker').with(
              'ensure'    => 'stopped',
              'enable'    => false,
              'hasstatus' => true
            ) }

            it { is_expected.to contain_package('uitdatabank-articlelinker').that_requires('Apt::Source[uitdatabank-articlelinker-alternative]') }
          end
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
