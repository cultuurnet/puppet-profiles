describe 'profiles::uitdatabank::entry_api::deployment::container' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) { 'realize(Group["www-data"], User["www-data"])' }

      context 'with image => registry.example.com/uitdatabank/entry-api' do
        let(:params) { {
          'image' => 'registry.example.com/uitdatabank/entry-api'
        } }

        context 'in the acceptance environment' do
          let(:environment) { 'acceptance' }
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::container').with(
            'image'                          => 'registry.example.com/uitdatabank/entry-api',
            'basedir'                        => '/var/www/udb3-backend',
            'aws_region'                     => 'eu-west-1',
            'image_tag'                      => nil,
            'api_keys_matched_to_client_ids' => false,
            'amqp_listener_uitpas'           => 'present',
            'bulk_label_offer_worker'        => 'present',
            'mail_worker'                    => 'present',
            'event_export_worker_count'      => 1
          ) }

          it { is_expected.to contain_class('profiles::docker') }

          it { is_expected.to contain_class('profiles::docker::ecr_repos').with(
            'repos' => {
              'uitdatabank/entry-api' => {
                'region'    => 'eu-west-1',
                'image_tag' => 'acceptance'
              }
            }
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with(
            'ensure' => 'file',
            'path'   => '/etc/uitdatabank-entry-api/docker-compose.yml',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644'
          ) }

          it { is_expected.to contain_exec('uitdatabank-entry-api-docker-compose').with(
            'command'     => '/usr/bin/docker compose -f /etc/uitdatabank-entry-api/docker-compose.yml up -d --remove-orphans',
            'refreshonly' => true
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').that_notifies('Exec[uitdatabank-entry-api-docker-compose]') }

          it { is_expected.to contain_file('/var/www/udb3-backend/web').with(
            'ensure' => 'directory',
            'owner'  => 'www-data',
            'group'  => 'www-data'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/web/.htaccess').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data'
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(/^\s+image: registry.example.com\/uitdatabank\/entry-api:latest$/) }
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(/^\s+command: \["php", "vendor\/chrisboulton\/php-resque\/bin\/resque"\]$/) }
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(/QUEUE: bulk_label_offer/) }
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(/QUEUE: mails/) }
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(/QUEUE: event_export/) }
          # bin/udb3.php special-cases this exact command name to set API_NAME
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(/\["php", "bin\/udb3.php", "amqp-listen-uitpas"\]/) }

          # the app requires these exact filenames
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(%r{:/var/www/html/config\.external_id_mapping_organizer\.php:ro}) }
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(%r{:/var/www/html/config\.external_id_mapping_place\.php:ro}) }
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(%r{public-uitidv1\.pem:/var/www/html/public\.pem:ro}) }
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(%r{/etc/uitdatabank-entry-api/config.external_id_mapping_organizer.php:}) }
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(%r{/etc/uitdatabank-entry-api/public-uitidv1.pem:}) }
          it { is_expected.not_to contain_file('uitdatabank-entry-api-docker-compose').with_content(/api_keys_matched_to_client_ids/) }
        end
      end

      context 'with image => myregistry.example.com/uitdatabank/entry-api, image_tag => foo, aws_region => us-east-1, api_keys_matched_to_client_ids => true, amqp_listener_uitpas => absent, mail_worker => absent and event_export_worker_count => 2' do
        let(:params) { {
          'image'                          => 'myregistry.example.com/uitdatabank/entry-api',
          'image_tag'                      => 'foo',
          'aws_region'                     => 'us-east-1',
          'api_keys_matched_to_client_ids' => true,
          'amqp_listener_uitpas'           => 'absent',
          'mail_worker'                    => 'absent',
          'event_export_worker_count'      => 2
        } }

        context 'in the testing environment' do
          let(:environment) { 'testing' }
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_class('profiles::docker::ecr_repos').with(
            'repos' => {
              'uitdatabank/entry-api' => {
                'region'    => 'us-east-1',
                'image_tag' => 'testing'
              }
            }
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(/^\s+image: myregistry.example.com\/uitdatabank\/entry-api:foo$/) }
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(%r{/etc/uitdatabank-entry-api/config\.api_keys_matched_to_client_ids\.php:/var/www/html/config\.api_keys_matched_to_client_ids\.php:ro}) }
          it { is_expected.not_to contain_file('uitdatabank-entry-api-docker-compose').with_content(/QUEUE: mails/) }
          it { is_expected.not_to contain_file('uitdatabank-entry-api-docker-compose').with_content(/amqp-listen-uitpas/) }
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(/event-export-worker-1/) }
          it { is_expected.to contain_file('uitdatabank-entry-api-docker-compose').with_content(/event-export-worker-2/) }
        end
      end

      context 'without image parameter' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'image'/) }
      end
    end
  end
end
