describe 'profiles::uit::frontend::deployment' do
  context "with config_source => /foo" do
    let(:params) { {
      'config_source' => '/foo'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uit::frontend::deployment').with(
          'config_source'     => '/foo',
          'maximum_heap_size' => 512,
          'version'           => 'latest',
          'repository'        => 'uit-frontend',
          'service_status'    => 'running',
          'service_address'   => '127.0.0.1',
          'service_port'      => 3000,
          'service_watchdog'  => false,
          'puppetdb_url'      => nil
        ) }

        it { is_expected.to contain_apt__source('uit-frontend') }
        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_package('uit-frontend').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uit-frontend').that_notifies('Profiles::Deployment::Versions[profiles::uit::frontend::deployment]') }
        it { is_expected.to contain_package('uit-frontend').that_requires('Apt::Source[uit-frontend]') }

        it { is_expected.to contain_file('uit-frontend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-frontend/packages/app/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uit-frontend-config').that_requires('Package[uit-frontend]') }

        it { is_expected.to contain_file('uit-frontend-service-defaults').with(
          'ensure' => 'file',
          'path'   => '/etc/default/uit-frontend',
          'owner'  => 'root',
          'group'  => 'root'
        ) }

        it { is_expected.to contain_file('uit-frontend-service-defaults').with_content(/^HOST=127.0.0.1$/) }
        it { is_expected.to contain_file('uit-frontend-service-defaults').with_content(/^NUXT_PORT=3000$/) }
        it { is_expected.to contain_file('uit-frontend-service-defaults').with_content(/^NODE_OPTIONS=--max_old_space_size=512$/) }

        it { is_expected.to contain_service('uit-frontend').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_profiles__systemd__service_watchdog('uit-frontend').with(
          'ensure'      => 'absent',
          'healthcheck' => "current_memory_mb=\$(( \$(/usr/bin/systemctl show -p MemoryCurrent --value \${SERVICE}) / (1024 * 1024) ))\nmaximum_memory_mb=\$(( 512 * 9 / 10 ))\n\n/usr/bin/test \${current_memory_mb} -lt \${maximum_memory_mb}\n"
        ) }

        it { is_expected.to contain_package('uit-frontend').that_notifies('Service[uit-frontend]') }
        it { is_expected.to contain_file('uit-frontend-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uit-frontend-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uit-frontend-config').that_notifies('Service[uit-frontend]') }
        it { is_expected.to contain_file('uit-frontend-service-defaults').that_notifies('Service[uit-frontend]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::frontend::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::frontend::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end
    end
  end

  context "with config_source => /bar, maximum_heap_size => 1024, service_address => 0.0.0.0, service_port => 3456, version => 1.2.3, repository => uit-frontend-exotic, service_status => stopped, service_watchdog => true and puppetdb_url => http://example.com:8000" do
    let(:params) { {
      'config_source'     => '/bar',
      'version'           => '1.2.3',
      'maximum_heap_size' => 1024,
      'repository'        => 'uit-frontend-exotic',
      'service_status'    => 'stopped',
      'service_address'   => '0.0.0.0',
      'service_port'      => 3456,
      'service_watchdog'  => true,
      'puppetdb_url'      => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "with repository uit-frontend-exotic defined" do
          let(:pre_condition) { '@apt::source { "uit-frontend-exotic": location => "http://localhost", release => "focal", repos => "main" }' }

          it { is_expected.to contain_apt__source('uit-frontend-exotic') }

          it { is_expected.to contain_file('uit-frontend-config').with(
            'source' => '/bar',
          ) }

          it { is_expected.to contain_file('uit-frontend-service-defaults').with_content(/^HOST=0.0.0.0$/) }
          it { is_expected.to contain_file('uit-frontend-service-defaults').with_content(/^NUXT_PORT=3456$/) }
          it { is_expected.to contain_file('uit-frontend-service-defaults').with_content(/^NODE_OPTIONS=--max_old_space_size=1024$/) }

          it { is_expected.to contain_package('uit-frontend').with( 'ensure' => '1.2.3') }

          it { is_expected.to contain_service('uit-frontend').with(
            'ensure'    => 'stopped',
            'enable'    => false
          ) }

          it { is_expected.to contain_profiles__systemd__service_watchdog('uit-frontend').with(
            'ensure'      => 'present',
            'healthcheck' => "current_memory_mb=\$(( \$(/usr/bin/systemctl show -p MemoryCurrent --value \${SERVICE}) / (1024 * 1024) ))\nmaximum_memory_mb=\$(( 1024 * 9 / 10 ))\n\n/usr/bin/test \${current_memory_mb} -lt \${maximum_memory_mb}\n"
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::frontend::deployment').with(
            'puppetdb_url' => 'http://example.com:8000'
          ) }
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
