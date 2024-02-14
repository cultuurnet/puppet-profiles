describe 'profiles::uit::cms::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => /foo and drush_config_source => /bar" do
        let(:params) { {
          'config_source'       => '/foo',
          'drush_config_source' => '/bar'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uit::cms::deployment').with(
          'config_source'       => '/foo',
          'drush_config_source' => '/bar',
          'version'             => 'latest',
          'repository'          => 'uit-cms',
          'puppetdb_url'        => nil
        )}

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }
        it { is_expected.to contain_apt__source('uit-cms') }

        it { is_expected.to contain_package('uit-cms').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('uit-cms-settings').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-cms/web/sites/default/settings.private.php',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uit-cms-drush-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-cms/drush/drush.yml',
          'source' => '/bar',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_exec('uit-cms-cache-rebuild pre').with(
          'command'     => 'drush cache:rebuild',
          'cwd'         => '/var/www/uit-cms',
          'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/var/www/uit-cms/vendor/bin'],
          'environment' => ['HOME=/'],
          'user'        => 'www-data',
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('uit-cms-updatedb').with(
          'command'     => 'drush updatedb -y',
          'cwd'         => '/var/www/uit-cms',
          'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/var/www/uit-cms/vendor/bin'],
          'environment' => ['HOME=/'],
          'user'        => 'www-data',
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('uit-cms-config-import').with(
          'command'     => 'drush config:import -y',
          'cwd'         => '/var/www/uit-cms',
          'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/var/www/uit-cms/vendor/bin'],
          'environment' => ['HOME=/'],
          'user'        => 'www-data',
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('uit-cms-cache-rebuild post').with(
          'command'     => 'drush cache:rebuild',
          'cwd'         => '/var/www/uit-cms',
          'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/var/www/uit-cms/vendor/bin'],
          'environment' => ['HOME=/'],
          'user'        => 'www-data',
          'refreshonly' => true
        ) }

        it { is_expected.to contain_cron('uit-cms-core-cron').with(
          'command'     => '/var/www/uit-cms/vendor/bin/drush -q core:cron',
          'environment' => ['MAILTO=infra@publiq.be'],
          'user'        => 'www-data',
          'hour'        => '*',
          'minute'      => ['0', '30']
        ) }

        it { is_expected.to contain_cron('uit-cms-curator-sync').with(
          'command'     => '/var/www/uit-cms/vendor/bin/drush -q queue-run curator_sync',
          'environment' => ['MAILTO=infra@publiq.be'],
          'user'        => 'www-data',
          'hour'        => '*',
          'minute'      => '*'
        ) }

        it { is_expected.to contain_profiles__php__fpm_service_alias('uit-cms') }

        it { is_expected.to contain_service('uit-cms').with(
          'hasstatus'  => true,
          'hasrestart' => true,
          'restart'    => '/usr/bin/systemctl reload uit-cms'
        ) }

        it { is_expected.to contain_file('uit-cms-settings').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uit-cms-settings').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uit-cms-settings').that_requires('Package[uit-cms]') }
        it { is_expected.to contain_file('uit-cms-settings').that_notifies('Service[uit-cms]') }
        it { is_expected.to contain_file('uit-cms-drush-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uit-cms-drush-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uit-cms-drush-config').that_requires('Package[uit-cms]') }
        it { is_expected.to contain_file('uit-cms-drush-config').that_notifies('Service[uit-cms]') }
        it { is_expected.to contain_exec('uit-cms-cache-rebuild pre').that_requires('User[www-data]') }
        it { is_expected.to contain_exec('uit-cms-cache-rebuild pre').that_subscribes_to('Package[uit-cms]') }
        it { is_expected.to contain_exec('uit-cms-cache-rebuild pre').that_subscribes_to('File[uit-cms-settings]') }
        it { is_expected.to contain_exec('uit-cms-cache-rebuild pre').that_subscribes_to('File[uit-cms-drush-config]') }
        it { is_expected.to contain_exec('uit-cms-updatedb').that_requires('User[www-data]') }
        it { is_expected.to contain_exec('uit-cms-updatedb').that_subscribes_to('Package[uit-cms]') }
        it { is_expected.to contain_exec('uit-cms-updatedb').that_subscribes_to('File[uit-cms-settings]') }
        it { is_expected.to contain_exec('uit-cms-updatedb').that_subscribes_to('File[uit-cms-drush-config]') }
        it { is_expected.to contain_exec('uit-cms-updatedb').that_requires('Exec[uit-cms-cache-rebuild pre]') }
        it { is_expected.to contain_exec('uit-cms-config-import').that_requires('User[www-data]') }
        it { is_expected.to contain_exec('uit-cms-config-import').that_subscribes_to('Package[uit-cms]') }
        it { is_expected.to contain_exec('uit-cms-config-import').that_subscribes_to('File[uit-cms-settings]') }
        it { is_expected.to contain_exec('uit-cms-config-import').that_subscribes_to('File[uit-cms-drush-config]') }
        it { is_expected.to contain_exec('uit-cms-config-import').that_requires('Exec[uit-cms-updatedb]') }
        it { is_expected.to contain_exec('uit-cms-cache-rebuild post').that_requires('User[www-data]') }
        it { is_expected.to contain_exec('uit-cms-cache-rebuild post').that_subscribes_to('Package[uit-cms]') }
        it { is_expected.to contain_exec('uit-cms-cache-rebuild post').that_subscribes_to('File[uit-cms-settings]') }
        it { is_expected.to contain_exec('uit-cms-cache-rebuild post').that_subscribes_to('File[uit-cms-drush-config]') }
        it { is_expected.to contain_exec('uit-cms-cache-rebuild post').that_requires('Exec[uit-cms-config-import]') }
        it { is_expected.to contain_cron('uit-cms-core-cron').that_requires('User[www-data]') }
        it { is_expected.to contain_cron('uit-cms-core-cron').that_requires('Exec[uit-cms-cache-rebuild post]') }
        it { is_expected.to contain_cron('uit-cms-curator-sync').that_requires('User[www-data]') }
        it { is_expected.to contain_cron('uit-cms-curator-sync').that_requires('Exec[uit-cms-cache-rebuild post]') }
        it { is_expected.to contain_service('uit-cms').that_requires('Profiles::Php::Fpm_service_alias[uit-cms]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::cms::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::cms::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context "with config_source => /baz, drush_config_source => /zzz, version => 1.2.3 and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'config_source'       => '/baz',
          'drush_config_source' => '/zzz',
          'version'             => '1.2.3',
          'repository'          => 'uit-cms-branch',
          'puppetdb_url'        => 'http://example.com:8000'
        } }

        context "with repository bla defined" do
          let(:pre_condition) { '@apt::source { "uit-cms-branch": location => "http://localhost", release => "focal", repos => "main" }' }

          it { is_expected.to contain_apt__source('uit-cms-branch') }

          it { is_expected.to contain_package('uit-cms').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_file('uit-cms-settings').with(
            'source' => '/baz'
          ) }

          it { is_expected.to contain_file('uit-cms-drush-config').with(
            'source' => '/zzz'
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::cms::deployment').with(
            'puppetdb_url' => 'http://example.com:8000'
          ) }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'drush_config_source'/) }
      end
    end
  end
end
