describe 'profiles::uitpas::website::frontend::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with config_source => appconfig/uitpas/website/frontend/env' do
          let(:params) { {
            'config_source'      => 'appconfig/uitpas/website/frontend/env'
          } }

          context 'without extra parameters' do
            let(:params) {
              super().merge({})
            }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitpas::website::frontend::deployment').with(
              'config_source'               => 'appconfig/uitpas/website/frontend/env',
              'version'                     => 'latest',
              'repository'                  => 'uitpas-website-frontend',
              'service_status'              => 'running',
              'service_address'             => '127.0.0.1',
              'service_port'                => '3000',
              'puppetdb_url'                => 'http://localhost:8081'
            ) }
          end

          it { is_expected.to contain_apt__source('uitpas-website-frontend') }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_package('uitpas-website-frontend').with(
            'ensure' => 'latest'
          ) }

          it { is_expected.to contain_file('uitpas-website-frontend-config').with(
            'ensure' => 'file',
            'path'   => '/var/www/uitpas-website-frontend/.env',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'content' => "UITPAS_FRONTEND_KEY=uitpas_frontend_value\n"
          ) }

          it { is_expected.to contain_file('uitpas-website-frontend-service-defaults').with(
            'ensure' => 'file',
            'path'   => '/etc/default/uitpas-website-frontend',
            'owner'  => 'root',
            'group'  => 'root',
            'content' => "NUXT_HOST=127.0.0.1\nNUXT_PORT=3000\n"
          ) }

          it { is_expected.to contain_service('uitpas-website-frontend').with(
            'enable'    => true,
            'ensure'    => 'running',
            'hasstatus' => true
          ) }

          it { is_expected.to contain_package('uitpas-website-frontend').that_requires('Apt::Source[uitpas-website-frontend]') }
          it { is_expected.to contain_file('uitpas-website-frontend-config').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitpas-website-frontend-config').that_notifies('Service[uitpas-website-frontend]') }
          it { is_expected.to contain_file('uitpas-website-frontend-service-defaults') }
        end
      end

      context 'without hieradata' do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

        context 'with config_source => appconfig/uitpas/website/frontend/env' do
          let(:params) { {
            'config_source' => 'appconfig/uitpas/website/frontend/env'
          } }

          it { is_expected.to contain_class('profiles::uitpas::website::frontend::deployment').with(
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
