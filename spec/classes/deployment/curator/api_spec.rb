require 'spec_helper'

describe 'profiles::deployment::curator::api' do
  context "with config_source => /foo" do
    let(:params) { {
      'config_source' => '/foo'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__apt__update('publiq-curator') }

        it { is_expected.to contain_package('curator-api').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('curator-api').that_notifies('Profiles::Deployment::Versions[profiles::deployment::curator::api]') }
        it { is_expected.to contain_package('curator-api').that_requires('Profiles::Apt::Update[publiq-curator]') }

        it { is_expected.to contain_file('curator-api-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/curator-api/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('curator-api-config').that_requires('Package[curator-api]') }

        it { is_expected.to contain_file('curator-api-var').with(
          'path'    => '/var/www/curator-api/var',
          'owner'   => 'www-data',
          'group'   => 'www-data',
          'recurse' => true
        ) }

        it { is_expected.to contain_file('curator-api-var').that_comes_before('Exec[curator-api_cache_clear]') }

        it { is_expected.to contain_exec('curator-api_db_schema_update').with(
          'command'     => 'php bin/console doctrine:migrations:migrate --no-interaction',
          'cwd'         => '/var/www/curator-api',
          'user'        => 'www-data',
          'group'       => 'www-data',
          'path'        => [ '/usr/local/bin', '/usr/bin', '/bin', '/var/www/curator-api'],
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('curator-api_db_schema_update').that_subscribes_to('Package[curator-api]') }

        it { is_expected.to contain_exec('curator-api_cache_clear').with(
          'command'     => 'php bin/console cache:clear',
          'cwd'         => '/var/www/curator-api',
          'user'        => 'www-data',
          'group'       => 'www-data',
          'path'        => [ '/usr/local/bin', '/usr/bin', '/bin', '/var/www/curator-api'],
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('curator-api_cache_clear').that_subscribes_to('Package[curator-api]') }
        it { is_expected.to contain_exec('curator-api_cache_clear').that_requires('Exec[curator-api_db_schema_update]') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::curator::api').with(
          'project'      => 'curator',
          'packages'     => 'curator-api',
          'puppetdb_url' => nil
        ) }
      end
    end
  end

  context "with config_source => /bar, version => 9.8.7 and puppetdb_url => http://example.com:8000" do
    let(:params) { {
      'config_source' => '/bar',
      'version'       => '9.8.7',
      'puppetdb_url'  => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to contain_file('curator-api-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_package('curator-api').with( 'ensure' => '9.8.7') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::curator::api').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }
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
