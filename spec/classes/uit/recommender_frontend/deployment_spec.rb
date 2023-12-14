describe 'profiles::uit::recommender_frontend::deployment' do
  context "with config_source => /foo" do
    let(:params) { {
      'config_source' => '/foo'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('uit-recommender-frontend') }

        it { is_expected.to contain_package('uit-recommender-frontend').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uit-recommender-frontend').that_notifies('Profiles::Deployment::Versions[profiles::uit::recommender_frontend::deployment]') }
        it { is_expected.to contain_package('uit-recommender-frontend').that_requires('Apt::Source[uit-recommender-frontend]') }

        it { is_expected.to contain_file('uit-recommender-frontend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-recommender-frontend/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uit-recommender-frontend-config').that_requires('Package[uit-recommender-frontend]') }

        it { is_expected.not_to contain_file('uit-recommender-frontend-service-defaults') }

        it { is_expected.to contain_service('uit-recommender-frontend').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('uit-recommender-frontend').that_subscribes_to('Package[uit-recommender-frontend]') }
        it { is_expected.to contain_service('uit-recommender-frontend').that_subscribes_to('File[uit-recommender-frontend-config]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::recommender_frontend::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::recommender_frontend::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end

        context "with service_defaults_source => '/tmp/service_defaults'" do
          let(:params) {
            super().merge({
              'service_defaults_source' => '/tmp/service_defaults'
            } )
          }

          it { is_expected.to contain_file('uit-recommender-frontend-service-defaults').with(
            'ensure' => 'file',
            'path'   => '/etc/default/uit-recommender-frontend',
            'source' => '/tmp/service_defaults',
            'owner'  => 'root',
            'group'  => 'root'
          ) }

          it { is_expected.to contain_file('uit-recommender-frontend-service-defaults').that_notifies('Service[uit-recommender-frontend]') }
        end

        context "with service_manage => false" do
          let(:params) {
            super().merge({
              'service_manage' => false
            } )
          }

          it { is_expected.not_to contain_file('uit-recommender-frontend-service-defaults') }

          it { is_expected.not_to contain_service('uit-recommender-frontend') }
        end
      end
    end
  end

  context "with config_source => /bar, version => 1.2.3, service_ensure => stopped, service_enable = false, service_defaults_source => /tmp/config and puppetdb_url => http://example.com:8000" do
    let(:params) { {
      'config_source'           => '/bar',
      'version'                 => '1.2.3',
      'service_ensure'          => 'stopped',
      'service_enable'          => false,
      'service_defaults_source' => '/tmp/config',
      'puppetdb_url'            => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to contain_file('uit-recommender-frontend-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_package('uit-recommender-frontend').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_service('uit-recommender-frontend').with(
          'ensure'    => 'stopped',
          'enable'    => false
        ) }

        it { is_expected.to contain_file('uit-recommender-frontend-service-defaults').with(
          'source' => '/tmp/config'
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::uit::recommender_frontend::deployment').with(
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
