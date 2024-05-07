describe 'profiles::publiq::versions::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::publiq::versions::deployment').with(
            'version'         => 'latest',
            'repository'      => 'publiq-versions',
            'service_address' => '127.0.0.1',
            'service_port'    => 3000,
            'service_status'  => 'running',
            'puppetdb_url'    => nil
          ) }

          it { is_expected.to contain_apt__source('publiq-versions') }
          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_package('publiq-versions').with('ensure' => 'latest') }

          it { is_expected.to contain_file('publiq-versions-service-defaults').with(
            'ensure' => 'file',
            'path'   => '/etc/default/publiq-versions',
            'owner'  => 'root',
            'group'  => 'root'
          ) }

          it { is_expected.to contain_file('publiq-versions-service-defaults').with_content(/^LISTEN_ADDRESS=127\.0\.0\.1$/) }
          it { is_expected.to contain_file('publiq-versions-service-defaults').with_content(/^LISTEN_PORT=3000$/) }

          it { is_expected.to contain_service('publiq-versions').with(
            'ensure'    => 'running',
            'hasstatus' => true,
            'enable'    => true
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::versions::deployment').with(
            'puppetdb_url' => nil
          ) }

          it { is_expected.to contain_package('publiq-versions').that_notifies('Profiles::Deployment::Versions[profiles::publiq::versions::deployment]') }
          it { is_expected.to contain_package('publiq-versions').that_notifies('Service[publiq-versions]') }
          it { is_expected.to contain_package('publiq-versions').that_requires('Apt::Source[publiq-versions]') }
          it { is_expected.to contain_file('publiq-versions-service-defaults').that_notifies('Service[publiq-versions]') }
        end

        context "with hieradata for profiles::publiq::versions" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_file('publiq-versions-service-defaults').with_content(/^LISTEN_ADDRESS=127\.0\.1\.1$/) }
          it { is_expected.to contain_file('publiq-versions-service-defaults').with_content(/^LISTEN_PORT=6000$/) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::versions::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context "with version => 1.2.3, repository => publiq-versions-alternative, service_address => 0.0.0.0, service_port => 5000, service_status => stopped and puppetdb_url => 'http://localhost:9000'" do
        let(:params) { {
          'version'         => '1.2.3',
          'repository'      => 'publiq-versions-alternative',
          'service_address' => '0.0.0.0',
          'service_port'    => 5000,
          'service_status'  => 'stopped',
          'puppetdb_url'    => 'http://localhost:9000'
        } }

        context "with repository publiq-versions-alternative defined" do
          let(:pre_condition) { '@apt::source { "publiq-versions-alternative": location => "http://localhost", release => "focal", repos => "main" }' }

          it { is_expected.to contain_apt__source('publiq-versions-alternative') }
          it { is_expected.to contain_package('publiq-versions').with('ensure' => '1.2.3') }

          it { is_expected.to contain_file('publiq-versions-service-defaults').with_content(/^LISTEN_ADDRESS=0\.0\.0\.0$/) }
          it { is_expected.to contain_file('publiq-versions-service-defaults').with_content(/^LISTEN_PORT=5000$/) }

          it { is_expected.to contain_service('publiq-versions').with(
            'ensure'    => 'stopped',
            'hasstatus' => true,
            'enable'    => false
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::versions::deployment').with(
            'puppetdb_url' => 'http://localhost:9000'
          ) }

          it { is_expected.to contain_package('publiq-versions').that_requires('Apt::Source[publiq-versions-alternative]') }
          it { is_expected.to contain_file('publiq-versions-service-defaults').that_notifies('Service[publiq-versions]') }
        end
      end
    end
  end
end
