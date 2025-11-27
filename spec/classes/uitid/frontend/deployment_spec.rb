describe 'profiles::uitid::frontend::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => appconfig/uitid/frontend/env' do
        let(:params) { {
          'config_source' => 'appconfig/uitid/frontend/env'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitid::frontend::deployment').with(
            'config_source'     => 'appconfig/uitid/frontend/env',
            'maximum_heap_size' => 512,
            'version'           => 'latest',
            'repository'        => 'uitid-frontend',
            'service_status'    => 'running',
            'service_address'   => '127.0.0.1',
            'service_port'      => 3000,
            'puppetdb_url'      => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_apt__source('uitid-frontend') }
          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_package('uitid-frontend').with('ensure' => 'latest') }

          it { is_expected.to contain_file('uitid-frontend-config').with(
            'ensure' => 'file',
            'path'   => '/var/www/uitid-frontend/app/.env',
            'content' => "KEY=value\n",
            'owner'  => 'www-data',
            'group'  => 'www-data'
          ) }

          it { is_expected.to contain_file('uitid-frontend-service-defaults').with(
            'ensure' => 'file',
            'path'   => '/etc/default/uitid-frontend',
            'owner'  => 'root',
            'group'  => 'root'
          ) }

          it { is_expected.to contain_service('uitid-frontend').with(
            'ensure'    => 'running',
            'enable'    => true,
            'hasstatus' => true
          ) }

          it { is_expected.to contain_file('uitid-frontend-service-defaults').with_content(/^NUXT_HOST=127.0.0.1$/) }
          it { is_expected.to contain_file('uitid-frontend-service-defaults').with_content(/^NUXT_PORT=3000$/) }
          it { is_expected.to contain_file('uitid-frontend-service-defaults').with_content(/^NODE_OPTIONS=--max_old_space_size=512$/) }
          it { is_expected.to contain_file('uitid-frontend-service-defaults').with_content(/^NUXT_TELEMETRY_DISABLED=1$/) }
          it { is_expected.to contain_file('uitid-frontend-service-defaults').with_content(/^DOTENV_CONFIG_PATH=\/var\/www\/uitid-frontend\/app\/\.env$/) }

          it { is_expected.to contain_package('uitid-frontend').that_requires('Apt::Source[uitid-frontend]') }
          it { is_expected.to contain_package('uitid-frontend').that_notifies('Profiles::Deployment::Versions[profiles::uitid::frontend::deployment]') }
          it { is_expected.to contain_package('uitid-frontend').that_notifies('Service[uitid-frontend]') }
          it { is_expected.to contain_file('uitid-frontend-config').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitid-frontend-config').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitid-frontend-config').that_requires('Package[uitid-frontend]') }
          it { is_expected.to contain_file('uitid-frontend-config').that_notifies('Service[uitid-frontend]') }
          it { is_expected.to contain_file('uitid-frontend-service-defaults').that_notifies('Service[uitid-frontend]') }
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitid::frontend::deployment').with(
            'puppetdb_url' => nil
          ) }
        end
      end
    end
  end

  context "with config_source => appconfig/uitid/frontend/env, maximum_heap_size => 1024, service_address => 0.0.0.0, service_port => 3456, version => 1.2.3, repository => uitid-frontend-exotic, service_status => stopped and puppetdb_url => http://example.com:8000" do
    let(:params) { {
      'config_source'     => 'appconfig/uitid/frontend/env',
      'version'           => '1.2.3',
      'maximum_heap_size' => 1024,
      'repository'        => 'uitid-frontend-exotic',
      'service_status'    => 'stopped',
      'service_address'   => '0.0.0.0',
      'service_port'      => 3456,
      'puppetdb_url'      => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with repository uitid-frontend-exotic defined" do
            let(:pre_condition) { '@apt::source { "uitid-frontend-exotic": location => "http://localhost", release => "focal", repos => "main" }' }

            it { is_expected.to contain_apt__source('uitid-frontend-exotic') }

            it { is_expected.to contain_package('uitid-frontend').with('ensure' => '1.2.3') }

            it { is_expected.to contain_file('uitid-frontend-config').with(
              'content' => "KEY=value\n"
            ) }

          it { is_expected.to contain_file('uitid-frontend-service-defaults').with_content(/^NUXT_HOST=0.0.0.0$/) }
          it { is_expected.to contain_file('uitid-frontend-service-defaults').with_content(/^NUXT_PORT=3456$/) }
          it { is_expected.to contain_file('uitid-frontend-service-defaults').with_content(/^NODE_OPTIONS=--max_old_space_size=1024$/) }

          it { is_expected.to contain_service('uitid-frontend').with(
            'ensure' => 'stopped',
            'enable' => false
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitid::frontend::deployment').with(
            'puppetdb_url' => 'http://example.com:8000'
          ) }

          it { is_expected.to contain_package('uitid-frontend').that_requires('Apt::Source[uitid-frontend-exotic]') }
          end
        end
      end
    end
  end

  context "without parameters" do
    let(:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
