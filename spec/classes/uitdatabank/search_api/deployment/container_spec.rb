describe 'profiles::uitdatabank::search_api::deployment::container' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with image => registry.example.com/uitdatabank-search-api' do
        let(:params) { {
          'image' => 'registry.example.com/uitdatabank-search-api'
        } }

        context 'in the acceptance environment' do
          let(:environment) { 'acceptance' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::docker') }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment::container').with(
            'image'                          => 'registry.example.com/uitdatabank-search-api',
            'aws_region'                     => 'eu-west-1',
            'image_tag'                      => nil,
            'default_queries'                => false,
            'api_keys_matched_to_client_ids' => false
          ) }

          it { is_expected.to contain_class('profiles::docker::ecr_repos').with(
            'repos' => {
              'uitdatabank-search-api' => {
                'region'    => 'eu-west-1',
                'image_tag' => 'acceptance'
              }
            }
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-docker-compose').with(
            'ensure' => 'file',
            'path'   => '/etc/uitdatabank-search-api/docker-compose.yml',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644'
          ) }

          it { is_expected.to contain_cron('uitdatabank-search-api-reindex-permanent').with(
            'command'     => '/usr/bin/docker compose -f /etc/uitdatabank-search-api/docker-compose.yml exec -T search-api php bin/app.php udb3-core:reindex-permanent',
            'environment' => ['MAILTO=infra+cron@publiq.be'],
            'hour'        => '0',
            'minute'      => '0'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-docker-compose').with_content(/^\s+image: registry.example.com\/uitdatabank-search-api:latest$/) }
          it { is_expected.not_to contain_file('uitdatabank-search-api-docker-compose').with_content(/^\s+- \/etc\/uitdatabank-search-api\/default_queries.php:\/var\/www\/html\/default_queries.php:ro$/) }
          it { is_expected.not_to contain_file('uitdatabank-search-api-docker-compose').with_content(/^\s+- \/etc\/uitdatabank-search-api\/api_keys_matched_to_client_ids.php:\/var\/www\/html\/api_keys_matched_to_client_ids.php:ro$/) }

          it { is_expected.to contain_docker_compose('uitdatabank-search-api').with(
            'ensure'        => 'present',
            'compose_files' => ['/etc/uitdatabank-search-api/docker-compose.yml']
          ) }

          it { is_expected.to contain_cron('uitdatabank-search-api-reindex-permanent').with(
            'command'     => '/usr/bin/docker compose -f /etc/uitdatabank-search-api/docker-compose.yml exec -T search-api php bin/app.php udb3-core:reindex-permanent',
            'environment' => ['MAILTO=infra+cron@publiq.be'],
            'hour'        => '0',
            'minute'      => '0'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-docker-compose').that_notifies('Docker_compose[uitdatabank-search-api]') }
          it { is_expected.to contain_cron('uitdatabank-search-api-reindex-permanent').that_requires('Docker_compose[uitdatabank-search-api]') }
        end
      end

      context 'with image => myregistry.example.com/uitdatabank-search-api, image_tag => foo, aws_region => us-east-1, default_queries => true and api_keys_matched_to_client_ids => true' do
        let(:params) { {
          'image'                          => 'myregistry.example.com/uitdatabank-search-api',
          'image_tag'                      => 'foo',
          'aws_region'                     => 'us-east-1',
          'default_queries'                => true,
          'api_keys_matched_to_client_ids' => true
        } }

        context 'in the testing environment' do
          let(:environment) { 'testing' }

          it { is_expected.to contain_class('profiles::docker::ecr_repos').with(
            'repos' => {
              'uitdatabank-search-api' => {
                'region'    => 'us-east-1',
                'image_tag' => 'testing'
              }
            }
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-docker-compose').with_content(/^\s+image: myregistry.example.com\/uitdatabank-search-api:foo$/) }
          it { is_expected.to contain_file('uitdatabank-search-api-docker-compose').with_content(/^\s+- \/etc\/uitdatabank-search-api\/default_queries.php:\/var\/www\/html\/default_queries.php:ro$/) }
          it { is_expected.to contain_file('uitdatabank-search-api-docker-compose').with_content(/^\s+- \/etc\/uitdatabank-search-api\/api_keys_matched_to_client_ids.php:\/var\/www\/html\/api_keys_matched_to_client_ids.php:ro$/) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'image'/) }
      end
    end
  end
end
