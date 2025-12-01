describe 'profiles::uitpas::website::api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with config_source => appconfig/uitpas/website/api/env' do
          let(:params) { {
            'config_source'      => 'appconfig/uitpas/website/api/env'
          } }

          context 'without extra parameters' do
            let(:params) {
              super().merge({})
            }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::website::api::deployment').with(
              'config_source'               => 'appconfig/uitpas/website/api/env',
              'version'                     => 'latest',
              'repository'                  => 'uitpas-website-api',
              'puppetdb_url'                => 'http://localhost:8081'
            ) }
          end

          it { is_expected.to contain_apt__source('uitpas-website-api') }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_package('uitpas-website-api').with(
            'ensure' => 'latest'
          ) }

          it { is_expected.to contain_file('uitpas-website-api-config').with(
            'ensure' => 'file',
            'path'   => '/var/www/uitpas-website-api/.env',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'content' => "UITPAS_API_KEY=uitpas_api_value\n"
          ) }

          it { is_expected.to contain_exec('uitpasbe-api_cache_clear').with(
            'command'     => 'php bin/console cache:clear',
            'cwd'         => '/var/www/uitpas-website-api',
            'user'        => 'www-data',
            'group'       => 'www-data',
            'path'        => [ '/usr/local/bin', '/usr/bin', '/bin', '/var/www/uitpas-website-api'],
            'refreshonly' => true
          ) }

          it { is_expected.to contain_package('uitpas-website-api').that_requires('Apt::Source[uitpas-website-api]') }
          it { is_expected.to contain_file('uitpas-website-api-config').that_requires('Group[www-data]') }
        end
      end

      context 'without hieradata' do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

        context 'with config_source => appconfig/uitpas/website/api/env' do
          let(:params) { {
            'config_source' => 'appconfig/uitpas/website/api/env'
          } }

          it { is_expected.to contain_class('profiles::uitpas::website::api::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context 'without parameters' do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end
    end
  end
end
