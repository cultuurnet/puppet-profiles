describe 'profiles::uitid::frontend_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => /foo" do
        let(:params) { {
          'config_source' => '/foo'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitid::frontend_api::deployment').with(
          'config_source'     => '/foo',
          'maximum_heap_size' => 512,
          'version'           => 'latest',
          'repository'        => 'uitid-frontend-api',
          'service_status'    => 'running',
          'service_address'   => '127.0.0.1',
          'service_port'      => 4000,
          'puppetdb_url'      => nil
        ) }

        it { is_expected.to contain_apt__source('uitid-frontend-api') }
        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_package('uitid-frontend-api').with('ensure' => 'latest') }

        it { is_expected.to contain_file('uitid-frontend-api-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uitid-frontend-api/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitid-frontend-api-service-defaults').with(
          'ensure' => 'file',
          'path'   => '/etc/default/uitid-frontend-api',
          'owner'  => 'root',
          'group'  => 'root'
        ) }

        it { is_expected.to contain_file('uitid-frontend-api-service-defaults').with_content(/^HOST=127.0.0.1$/) }
        it { is_expected.to contain_file('uitid-frontend-api-service-defaults').with_content(/^PORT=4000$/) }
        it { is_expected.to contain_file('uitid-frontend-api-service-defaults').with_content(/^NODE_OPTIONS=--max_old_space_size=512$/) }

        it { is_expected.to contain_service('uitid-frontend-api').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_package('uitid-frontend-api').that_requires('Apt::Source[uitid-frontend-api]') }
        it { is_expected.to contain_package('uitid-frontend-api').that_notifies('Service[uitid-frontend-api]') }
        it { is_expected.to contain_package('uitid-frontend-api').that_notifies('Profiles::Deployment::Versions[profiles::uitid::frontend_api::deployment]') }
        it { is_expected.to contain_file('uitid-frontend-api-config').that_requires('Package[uitid-frontend-api]') }
        it { is_expected.to contain_file('uitid-frontend-api-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitid-frontend-api-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitid-frontend-api-config').that_notifies('Service[uitid-frontend-api]') }
        it { is_expected.to contain_file('uitid-frontend-api-service-defaults').that_notifies('Service[uitid-frontend-api]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitid::frontend_api::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitid::frontend_api::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context "with config_source => /bar, maximum_heap_size => 1024, service_address => 0.0.0.0, service_port => 3456, version => 1.2.3, repository => uitid-frontend-api-exotic, service_status => stopped and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'config_source'        => '/bar',
          'version'              => '1.2.3',
          'maximum_heap_size'    => 1024,
          'repository'           => 'uitid-frontend-api-exotic',
          'service_status'       => 'stopped',
          'service_address'      => '0.0.0.0',
          'service_port'         => 3456,
          'puppetdb_url'         => 'http://example.com:8000'
        } }

        context "with repository uitid-frontend-api-exotic defined" do
          let(:pre_condition) { '@apt::source { "uitid-frontend-api-exotic": location => "http://localhost", release => "focal", repos => "main" }' }

          it { is_expected.to contain_apt__source('uitid-frontend-api-exotic') }

          it { is_expected.to contain_file('uitid-frontend-api-config').with(
            'source' => '/bar'
          ) }

          it { is_expected.to contain_file('uitid-frontend-api-service-defaults').with_content(/^HOST=0.0.0.0$/) }
          it { is_expected.to contain_file('uitid-frontend-api-service-defaults').with_content(/^PORT=3456$/) }
          it { is_expected.to contain_file('uitid-frontend-api-service-defaults').with_content(/^NODE_OPTIONS=--max_old_space_size=1024$/) }

          it { is_expected.to contain_package('uitid-frontend-api').with('ensure' => '1.2.3') }

          it { is_expected.to contain_service('uitid-frontend-api').with(
            'ensure'    => 'stopped',
            'enable'    => false
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitid::frontend_api::deployment').with(
            'puppetdb_url' => 'http://example.com:8000'
          ) }

          it { is_expected.to contain_package('uitid-frontend-api').that_requires('Apt::Source[uitid-frontend-api-exotic]') }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
