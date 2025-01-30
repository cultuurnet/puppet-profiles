describe 'profiles::uitpas::cid_web::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => /foo' do
        let(:params) { {
          'config_source' => '/foo',
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitpas::cid_web::deployment').with(
          'config_source'   => '/foo',
          'version'         => 'latest',
          'repository'      => 'uitpas-cid-web',
          'service_status'  => 'running',
          'service_address' => '127.0.0.1',
          'service_port'    => '3000',
          'puppetdb_url'    => nil
        ) }

        it { is_expected.to contain_apt__source('uitpas-cid-web') }

        it { is_expected.to contain_package('uitpas-cid-web').with(
          'ensure' => 'latest'
        ) }
cid-web
        it { is_expected.to contain_file('uitpas-cid-web-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uitpas-cid-web/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitpas-cid-web-service-defaults').with(
          'ensure'  => 'file',
          'path'    => '/etc/default/uitpas-cid-web',
          'content' => ""
        ) }

        it { is_expected.to contain_service('uitpas-cid-web').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_package('uitpas-cid-web').that_notifies('Service[uitpas-cid-web]') }
        it { is_expected.to contain_package('uitpas-cid-web').that_notifies('Profiles::Deployment::Versions[profiles::uitpas::cid_web::deployment]') }
        it { is_expected.to contain_package('uitpas-cid-web').that_requires('Apt::Source[uitpas-cid-web]') }
        it { is_expected.to contain_file('uitpas-cid-web-config').that_requires('Package[uitpas-cid-web]') }
        it { is_expected.to contain_file('uitpas-cid-web-service-defaults').that_requires('Package[uitpas-cid-web]') }
        it { is_expected.to contain_file('uitpas-cid-web-config').that_notifies('Service[uitpas-cid-web]') }
        it { is_expected.to contain_file('uitpas-cid-web-service-defaults').that_notifies('Service[uitpas-cid-web]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::cid_web::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::cid_web::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context 'with repository uitpas-cid-web-alternative defined' do
        let(:pre_condition) { '@apt::source { "uitpas-cid-web-alternative": location => "http://localhost", release => "focal", repos => "main" }' }

        context 'with config_source => /bar, version => 1.2.3, repository => uitpas-cid-web-alternative, service_status => stopped, service_address => 0.0.0.0 and service_port => 6000 ' do
          let(:params) { {
            'config_source'   => '/bar',
            'version'         => '1.2.3',
            'repository'      => 'uitpas-frontend-alternative',
            'service_status'  => 'stopped',
            'service_address' => '0.0.0.0',
            'service_port'    => 6000
          } }

          it { is_expected.to contain_apt__source('uitpas-cid-web-alternative') }

          it { is_expected.to contain_package('uitpas-cid-web').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_file('uitpas-cid-web-service-defaults').with(
            'ensure'  => 'file',
            'path'    => '/etc/default/uitpas-cid-web',
            'content' => ""
          ) }

          it { is_expected.to contain_service('uitpas-cid-web').with(
            'ensure'    => 'stopped',
            'enable'    => false,
            'hasstatus' => true
          ) }

          it { is_expected.to contain_package('uitpas-cid-web').that_requires('Apt::Source[uitpas-cid-web-alternative]') }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
