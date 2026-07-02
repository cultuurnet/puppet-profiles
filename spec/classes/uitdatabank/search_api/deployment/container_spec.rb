describe 'profiles::uitdatabank::search_api::deployment::container' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'image'/) }
      end

      context "with image => 'registry.example.com/uitdatabank-search-api'" do
        let(:params) { {
          'image' => 'registry.example.com/uitdatabank-search-api'
        } }

        let(:pre_condition) { [
          'file { "/etc/uitdatabank-search-api": ensure => "directory" }',
          'file { "uitdatabank-search-api-config": path => "/etc/uitdatabank-search-api/config.php" }',
          'file { "uitdatabank-search-api-pubkey-keycloak": path => "/etc/uitdatabank-search-api/public-keycloak.pem" }',
        ] }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment::container').with(
          'image'      => 'registry.example.com/uitdatabank-search-api',
          'aws_region' => 'eu-west-1',
          'image_tag'  => nil
        ) }

        it { is_expected.to contain_class('profiles::docker::ecr_repos').with(
          'repos' => {
            'uitdatabank-search-api' => {
              'region'    => 'eu-west-1',
              'image_tag' => 'rp_env'
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
          'command'     => 'docker compose -f /etc/uitdatabank-search-api/docker-compose.yml exec -T search-api php bin/app.php udb3-core:reindex-permanent',
          'environment' => ['MAILTO=infra+cron@publiq.be'],
          'hour'        => '0',
          'minute'      => '0'
        ) }

        it { is_expected.to contain_file('uitdatabank-search-api-docker-compose').that_requires('File[/etc/uitdatabank-search-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-docker-compose').that_notifies('Docker_compose[uitdatabank-search-api]') }
        it { is_expected.to contain_cron('uitdatabank-search-api-reindex-permanent').that_requires('Docker_compose[uitdatabank-search-api]') }
      end

      context "with image => 'registry.example.com/uitdatabank-search-api' and aws_region => 'us-east-1'" do
        let(:params) { {
          'image'      => 'registry.example.com/uitdatabank-search-api',
          'aws_region' => 'us-east-1'
        } }

        let(:pre_condition) { [
          'file { "/etc/uitdatabank-search-api": ensure => "directory" }',
          'file { "uitdatabank-search-api-config": path => "/etc/uitdatabank-search-api/config.php" }',
          'file { "uitdatabank-search-api-pubkey-keycloak": path => "/etc/uitdatabank-search-api/public-keycloak.pem" }',
        ] }

        it { is_expected.to contain_class('profiles::docker::ecr_repos').with(
          'repos' => {
            'uitdatabank-search-api' => {
              'region'    => 'us-east-1',
              'image_tag' => 'rp_env'
            }
          }
        ) }
      end
    end
  end
end
