describe 'profiles::uitdatabank::entry_api::deployment::container' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with ecr_registry => registry.example.com and fpm_max_children => 24' do
        let(:params) { {
          'ecr_registry'     => 'registry.example.com',
          'fpm_max_children' => 24
        } }

        context 'in the acceptance environment' do
          let(:environment) { 'acceptance' }

          context 'with a docker image version tag available' do
            let(:pre_condition) { 'function ecr_docker_image_version_tag($parameter1, $parameter2) { return "2026.11.27.000000" }' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::docker') }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::container').with(
              'ecr_registry'                   => 'registry.example.com',
              'ecr_repository'                 => 'uitdatabank/entry-api',
              'image_tag'                      => '2026.11.27.000000',
              'fpm_max_children'               => 24,
              'fpm_max_requests'               => 10000,
              'db_migrate'                     => true,
              'api_keys_matched_to_client_ids' => false,
              'amqp_listener_uitpas'           => 'present',
              'bulk_label_offer_worker'        => 'present',
              'mail_worker'                    => 'present',
              'event_export_worker_count'      => 1
            ) }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }

            ['/var/lib/uitdatabank-entry-api', '/var/lib/uitdatabank-entry-api/downloads'].each do |dir|
              it { is_expected.to contain_file(dir).with(
                'ensure' => 'directory',
                'owner'  => 'www-data',
                'group'  => 'www-data'
              ) }

              it { is_expected.to contain_file(dir).that_comes_before('Docker_compose[uitdatabank-entry-api]') }
            end

            it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with(
              'ensure' => 'file',
              'path'   => '/etc/uitdatabank-entry-api/docker-compose.yml',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0644'
            ) }

            context 'with docker-compose YAML loaded' do
              let(:content) { YAML.load(catalogue.resource('file', 'uitdatabank-entry-api-docker-compose').send(:parameters)[:content], aliases: true) }

              it { expect(content['x-entry-api']['image']).to eq('registry.example.com/uitdatabank/entry-api:2026.11.27.000000') }
              it { expect(content['x-entry-api']['environment']).to eq({ 'LOG_TO_STDOUT' => 'true' }) }
              it { expect(content['x-entry-api']['volumes']).to include('/etc/uitdatabank-entry-api/config.php:/var/www/html/config.php:ro') }
              it { expect(content['x-entry-api']['volumes']).to include('/etc/uitdatabank-entry-api/config.external_id_mapping_organizer.php:/var/www/html/config.external_id_mapping_organizer.php:ro') }
              it { expect(content['x-entry-api']['volumes']).to include('/etc/uitdatabank-entry-api/public.pem:/var/www/html/public.pem:ro') }
              it { expect(content['x-entry-api']['volumes']).to include('/etc/uitdatabank-entry-api/fpm-pool.conf:/usr/local/etc/php-fpm.d/zz-pool.conf:ro') }
              it { expect(content['x-entry-api']['volumes']).to include('/var/lib/uitdatabank-entry-api/downloads:/var/www/html/web/downloads') }
              it { expect(content['x-entry-api']['volumes']).not_to include('/etc/uitdatabank-entry-api/config.api_keys_matched_to_client_ids.php:/var/www/html/config.api_keys_matched_to_client_ids.php:ro') }
              it { expect(content['services']['entry-web-assets']['command']).to eq(['cp', '-a', '/var/www/html/web/.', '/srv/web/']) }
              it { expect(content['services']['entry-nginx']['network_mode']).to eq('service:entry-api') }
              it { expect(content['services']['entry-nginx']['volumes']).to include('/etc/uitdatabank-entry-api/nginx.conf:/etc/nginx/conf.d/default.conf:ro') }
              it { expect(content['services']['entry-nginx']['volumes']).to include('entry-api-web:/var/www/html/web:ro') }
              it { expect(content['services']['bulk-label-offer-worker']['working_dir']).to eq('/var/www/html/vendor/chrisboulton/php-resque') }
              it { expect(content['services']['bulk-label-offer-worker']['command']).to eq(['php', 'resque.php']) }
              it { expect(content['services']['bulk-label-offer-worker']['environment']['QUEUE']).to eq('bulk_label_offer') }
              it { expect(content['services']['mail-worker']['environment']['QUEUE']).to eq('mails') }
              it { expect(content['services']['event-export-worker']['environment']).to eq({
                'LOG_TO_STDOUT' => 'true',
                'APP_INCLUDE'   => '/var/www/html/worker_bootstrap.php',
                'INTERVAL'      => '1',
                'QUEUE'         => 'event_export'
              }) }
              it { expect(content['services']['event-export-worker']['stop_grace_period']).to eq('900s') }
              it { expect(content['services']['event-export-worker']['scale']).to eq(1) }
              it { expect(content['services']['amqp-listener-uitpas']['command']).to eq(['php', 'bin/udb3.php', 'amqp-listen-uitpas']) }
            end

            it { is_expected.to contain_file('uitdatabank-entry-api-fpm-pool').with(
              'ensure' => 'file',
              'path'   => '/etc/uitdatabank-entry-api/fpm-pool.conf',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0644'
            ) }

            it { is_expected.to contain_file('uitdatabank-entry-api-fpm-pool').with_content(/^pm = static$/) }
            it { is_expected.to contain_file('uitdatabank-entry-api-fpm-pool').with_content(/^pm\.max_children = 24$/) }
            it { is_expected.to contain_file('uitdatabank-entry-api-fpm-pool').with_content(/^pm\.max_requests = 10000$/) }
            it { is_expected.to contain_file('uitdatabank-entry-api-fpm-pool').with_content(/^listen\.backlog = -1$/) }

            it { is_expected.to contain_file('uitdatabank-entry-api-nginx-conf').with(
              'ensure' => 'file',
              'path'   => '/etc/uitdatabank-entry-api/nginx.conf',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0644'
            ) }

            it { is_expected.to contain_file('uitdatabank-entry-api-nginx-conf').with_content(/fastcgi_pass 127\.0\.0\.1:9000;/) }
            it { is_expected.to contain_file('uitdatabank-entry-api-nginx-conf').with_content(%r{try_files \$uri /index\.php\$is_args\$args;}) }
            it { is_expected.to contain_file('uitdatabank-entry-api-nginx-conf').with_content(%r{default_type application/ld\+json;}) }
            it { is_expected.to contain_file('uitdatabank-entry-api-nginx-conf').with_content(/^\s+access_log off;$/) }

            it { is_expected.to contain_docker_compose('uitdatabank-entry-api').with(
              'ensure'        => 'present',
              'compose_files' => ['/etc/uitdatabank-entry-api/docker-compose.yml'],
              'scale'         => { 'event-export-worker' => 1 }
            ) }

            it { is_expected.to contain_exec('uitdatabank-entry-api-db-migrate').with(
              'command'     => '/usr/bin/docker compose -f /etc/uitdatabank-entry-api/docker-compose.yml exec -T entry-api vendor/bin/doctrine-dbal --no-interaction migrations:migrate',
              'refreshonly' => true
            ) }

            it { is_expected.to contain_exec('uitdatabank-entry-api-fpm-pool-reload').with(
              'command'     => '/usr/bin/docker compose -f /etc/uitdatabank-entry-api/docker-compose.yml kill -s SIGUSR2 entry-api',
              'refreshonly' => true
            ) }

            it { is_expected.to contain_exec('uitdatabank-entry-api-nginx-reload').with(
              'command'     => '/usr/bin/docker compose -f /etc/uitdatabank-entry-api/docker-compose.yml kill -s SIGHUP entry-nginx',
              'refreshonly' => true
            ) }

            it { is_expected.not_to contain_profiles__nfs__mount('foo.fs-1234.efs.eu-west-1.amazonaws.com:/') }

            it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').that_notifies('Docker_compose[uitdatabank-entry-api]') }
            it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').that_notifies('Exec[uitdatabank-entry-api-db-migrate]') }
            it { is_expected.to contain_exec('uitdatabank-entry-api-db-migrate').that_requires('Docker_compose[uitdatabank-entry-api]') }
            it { is_expected.to contain_file('uitdatabank-entry-api-fpm-pool').that_notifies('Exec[uitdatabank-entry-api-fpm-pool-reload]') }
            it { is_expected.to contain_file('uitdatabank-entry-api-fpm-pool').that_comes_before('Docker_compose[uitdatabank-entry-api]') }
            it { is_expected.to contain_exec('uitdatabank-entry-api-fpm-pool-reload').that_requires('Docker_compose[uitdatabank-entry-api]') }
            it { is_expected.to contain_file('uitdatabank-entry-api-nginx-conf').that_notifies('Exec[uitdatabank-entry-api-nginx-reload]') }
            it { is_expected.to contain_file('uitdatabank-entry-api-nginx-conf').that_comes_before('Docker_compose[uitdatabank-entry-api]') }
            it { is_expected.to contain_exec('uitdatabank-entry-api-nginx-reload').that_requires('Docker_compose[uitdatabank-entry-api]') }
            it { is_expected.to contain_docker_compose('uitdatabank-entry-api').that_requires('Class[profiles::docker]') }
          end
        end

        context 'with Terraform NFS mount hieradata' do
          let(:hiera_config) { 'spec/support/hiera/terraform_common.yaml' }
          let(:pre_condition) { 'function ecr_docker_image_version_tag($parameter1, $parameter2) { return "2026.11.27.000000" }' }

          it { is_expected.to contain_profiles__nfs__mount('foo.fs-1234.efs.eu-west-1.amazonaws.com:/').with(
            'mountpoint'    => '/var/lib/uitdatabank-entry-api/downloads',
            'mount_options' => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2',
            'owner'         => 'www-data',
            'group'         => 'www-data'
          ) }

          it { is_expected.to contain_profiles__nfs__mount('foo.fs-1234.efs.eu-west-1.amazonaws.com:/').that_requires('File[/var/lib/uitdatabank-entry-api/downloads]') }
          it { is_expected.to contain_profiles__nfs__mount('foo.fs-1234.efs.eu-west-1.amazonaws.com:/').that_comes_before('Docker_compose[uitdatabank-entry-api]') }
        end
      end

      context 'with ecr_registry => myregistry.example.com, ecr_repository => entry-api, image_tag => foo, fpm_max_children => 192, fpm_max_requests => 500, db_migrate => false, api_keys_matched_to_client_ids => true, amqp_listener_uitpas => absent, bulk_label_offer_worker => absent, mail_worker => absent and event_export_worker_count => 4' do
        let(:params) { {
          'ecr_registry'                   => 'myregistry.example.com',
          'ecr_repository'                 => 'entry-api',
          'image_tag'                      => 'foo',
          'fpm_max_children'               => 192,
          'fpm_max_requests'               => 500,
          'db_migrate'                     => false,
          'api_keys_matched_to_client_ids' => true,
          'amqp_listener_uitpas'           => 'absent',
          'bulk_label_offer_worker'        => 'absent',
          'mail_worker'                    => 'absent',
          'event_export_worker_count'      => 4
        } }

        context 'in the testing environment' do
          let(:environment) { 'testing' }

          it { is_expected.not_to contain_exec('uitdatabank-entry-api-db-migrate') }

          it { is_expected.to contain_file('uitdatabank-entry-api-fpm-pool').with_content(/^pm\.max_children = 192$/) }
          it { is_expected.to contain_file('uitdatabank-entry-api-fpm-pool').with_content(/^pm\.max_requests = 500$/) }

          it { is_expected.to contain_docker_compose('uitdatabank-entry-api').with(
            'scale' => { 'event-export-worker' => 4 }
          ) }

          context 'with docker-compose YAML loaded' do
            let(:content) { YAML.load(catalogue.resource('file', 'uitdatabank-entry-api-docker-compose').send(:parameters)[:content], aliases: true) }

            it { expect(content['x-entry-api']['image']).to eq('myregistry.example.com/entry-api:foo') }
            it { expect(content['x-entry-api']['volumes']).to include('/etc/uitdatabank-entry-api/config.api_keys_matched_to_client_ids.php:/var/www/html/config.api_keys_matched_to_client_ids.php:ro') }
            it { expect(content['services']['event-export-worker']['scale']).to eq(4) }
            it { expect(content['services'].keys).to contain_exactly('entry-web-assets', 'entry-api', 'entry-nginx', 'event-export-worker') }
          end

          context 'with event_export_worker_count => 0' do
            let(:params) { super().merge({ 'event_export_worker_count' => 0 }) }

            it { is_expected.to contain_docker_compose('uitdatabank-entry-api').with(
              'scale' => nil
            ) }

            it { expect(YAML.load(catalogue.resource('file', 'uitdatabank-entry-api-docker-compose').send(:parameters)[:content], aliases: true)['services'].keys).to contain_exactly('entry-web-assets', 'entry-api', 'entry-nginx') }
          end
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter \$ecr_registry/) }
      end
    end
  end
end
