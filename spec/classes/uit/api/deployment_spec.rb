describe 'profiles::uit::api::deployment' do
  context "with config_source => /foo" do
    let(:params) { {
      'config_source' => '/foo'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uit::api::deployment').with(
          'config_source'        => '/foo',
          'maximum_heap_size'    => 512,
          'version'              => 'latest',
          'repository'           => 'uit-api',
          'service_status'       => 'running',
          'service_port'         => 4000,
          'newrelic_license_key' => nil,
          'newrelic_app_name'    => nil,
          'puppetdb_url'         => nil
        ) }

        it { is_expected.to contain_apt__source('uit-api') }
        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_package('uit-api').with('ensure' => 'latest') }

        it { is_expected.to contain_file('uit-api-config-graphql').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-api/packages/graphql/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uit-api-config-db').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-api/packages/db/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uit-api-service-defaults').with(
          'ensure' => 'file',
          'path'   => '/etc/default/uit-api',
          'owner'  => 'root',
          'group'  => 'root'
        ) }

        it { is_expected.to contain_file('uit-api-service-defaults').with_content(/^PORT=4000$/) }
        it { is_expected.to contain_file('uit-api-service-defaults').with_content(/^NODE_OPTIONS=--max_old_space_size=512$/) }

        it { is_expected.to contain_exec('uit-api-graphql-schema-update').with(
          'command'     => 'yarn graphql typeorm migration:run',
          'cwd'         => '/var/www/uit-api',
          'user'        => 'www-data',
          'group'       => 'www-data',
          'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/var/www/uit-api'],
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('uit-api-db-schema-update').with(
          'command'     => 'yarn db typeorm migration:run',
          'cwd'         => '/var/www/uit-api',
          'user'        => 'www-data',
          'group'       => 'www-data',
          'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/var/www/uit-api'],
          'refreshonly' => true
        ) }

        it { is_expected.to contain_service('uit-api').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_package('uit-api').that_requires('Apt::Source[uit-api]') }
        it { is_expected.to contain_package('uit-api').that_notifies('Exec[uit-api-graphql-schema-update]') }
        it { is_expected.to contain_package('uit-api').that_notifies('Exec[uit-api-db-schema-update]') }
        it { is_expected.to contain_package('uit-api').that_notifies('Service[uit-api]') }
        it { is_expected.to contain_package('uit-api').that_notifies('Profiles::Deployment::Versions[profiles::uit::api::deployment]') }
        it { is_expected.to contain_file('uit-api-config-graphql').that_requires('Package[uit-api]') }
        it { is_expected.to contain_file('uit-api-config-graphql').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uit-api-config-graphql').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uit-api-config-graphql').that_notifies('Exec[uit-api-graphql-schema-update]') }
        it { is_expected.to contain_file('uit-api-config-graphql').that_notifies('Service[uit-api]') }
        it { is_expected.to contain_file('uit-api-config-db').that_requires('Package[uit-api]') }
        it { is_expected.to contain_file('uit-api-config-db').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uit-api-config-db').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uit-api-config-db').that_notifies('Exec[uit-api-db-schema-update]') }
        it { is_expected.to contain_file('uit-api-config-db').that_notifies('Service[uit-api]') }
        it { is_expected.to contain_file('uit-api-service-defaults').that_notifies('Service[uit-api]') }
        it { is_expected.to contain_exec('uit-api-graphql-schema-update').that_notifies('Service[uit-api]') }
        it { is_expected.to contain_exec('uit-api-graphql-schema-update').that_requires('Group[www-data]') }
        it { is_expected.to contain_exec('uit-api-graphql-schema-update').that_requires('User[www-data]') }
        it { is_expected.to contain_exec('uit-api-db-schema-update').that_notifies('Service[uit-api]') }
        it { is_expected.to contain_exec('uit-api-db-schema-update').that_requires('Group[www-data]') }
        it { is_expected.to contain_exec('uit-api-db-schema-update').that_requires('User[www-data]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::api::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::api::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end
    end
  end

  context "with config_source => /bar, maximum_heap_size => 1024, service_port => 3456, version => 1.2.3, repository => uit-api-exotic, service_status => stopped, newrelic_license_key => ping, newrelic_app_name => pong and puppetdb_url => http://example.com:8000" do
    let(:params) { {
      'config_source'        => '/bar',
      'version'              => '1.2.3',
      'maximum_heap_size'    => 1024,
      'repository'           => 'uit-api-exotic',
      'service_status'       => 'stopped',
      'service_port'         => 3456,
      'newrelic_license_key' => 'ping',
      'newrelic_app_name'    => 'pong',
      'puppetdb_url'         => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "with repository uit-api-exotic defined" do
          let(:pre_condition) { '@apt::source { "uit-api-exotic": location => "http://localhost", release => "focal", repos => "main" }' }

          it { is_expected.to contain_apt__source('uit-api-exotic') }

          it { is_expected.to contain_file('uit-api-config-graphql').with(
            'source' => '/bar'
          ) }

          it { is_expected.to contain_file('uit-api-config-db').with(
            'source' => '/bar'
          ) }

          it { is_expected.to contain_file('uit-api-service-defaults').with_content(/^PORT=3456$/) }
          it { is_expected.to contain_file('uit-api-service-defaults').with_content(/^NODE_OPTIONS=--max_old_space_size=1024$/) }
          it { is_expected.to contain_file('uit-api-service-defaults').with_content(/^NEW_RELIC_LICENSE_KEY=ping$/) }
          it { is_expected.to contain_file('uit-api-service-defaults').with_content(/^NEW_RELIC_APP_NAME=pong$/) }

          it { is_expected.to contain_package('uit-api').with('ensure' => '1.2.3') }

          it { is_expected.to contain_service('uit-api').with(
            'ensure'    => 'stopped',
            'enable'    => false
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::api::deployment').with(
            'puppetdb_url' => 'http://example.com:8000'
          ) }

          it { is_expected.to contain_package('uit-api').that_requires('Apt::Source[uit-api-exotic]') }
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
