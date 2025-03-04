describe 'profiles::uit::recommender_frontend::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => /foo" do
        let(:params) { {
          'config_source' => '/foo'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uit::recommender_frontend::deployment').with(
          'config_source'  => '/foo',
          'version'        => 'latest',
          'repository'     => 'uit-recommender-frontend',
          'service_status' => 'running',
          'service_port'   => 6000,
          'puppetdb_url'   => nil
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }
        it { is_expected.to contain_apt__source('uit-recommender-frontend') }

        it { is_expected.to contain_package('uit-recommender-frontend').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('uit-recommender-frontend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-recommender-frontend/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uit-recommender-frontend-service-defaults').with(
          'ensure' => 'file',
          'path'   => '/etc/default/uit-recommender-frontend'
        ) }

        it { is_expected.to contain_file('uit-recommender-frontend-service-defaults').with_content(/^PORT=6000$/) }

        it { is_expected.to contain_service('uit-recommender-frontend').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_package('uit-recommender-frontend').that_requires('Apt::Source[uit-recommender-frontend]') }
        it { is_expected.to contain_package('uit-recommender-frontend').that_notifies('Profiles::Deployment::Versions[profiles::uit::recommender_frontend::deployment]') }
        it { is_expected.to contain_file('uit-recommender-frontend-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uit-recommender-frontend-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uit-recommender-frontend-config').that_requires('Package[uit-recommender-frontend]') }
        it { is_expected.to contain_file('uit-recommender-frontend-service-defaults').that_requires('Package[uit-recommender-frontend]') }
        it { is_expected.to contain_service('uit-recommender-frontend').that_subscribes_to('Package[uit-recommender-frontend]') }
        it { is_expected.to contain_service('uit-recommender-frontend').that_subscribes_to('File[uit-recommender-frontend-config]') }
        it { is_expected.to contain_service('uit-recommender-frontend').that_subscribes_to('File[uit-recommender-frontend-service-defaults]') }

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
      end

      context "with config_source => /bar, version => 1.2.3, service_status => stopped, service_port = 9876 and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'config_source'           => '/bar',
          'version'                 => '1.2.3',
          'service_status'          => 'stopped',
          'service_port'            => 9876,
          'puppetdb_url'            => 'http://example.com:8000'
        } }

        it { is_expected.to contain_file('uit-recommender-frontend-config').with(
          'source' => '/bar'
        ) }

        it { is_expected.to contain_package('uit-recommender-frontend').with(
          'ensure' => '1.2.3'
        ) }

        it { is_expected.to contain_service('uit-recommender-frontend').with(
          'ensure' => 'stopped',
          'enable' => false
        ) }

        it { is_expected.to contain_file('uit-recommender-frontend-service-defaults').with_content(/^PORT=9876$/) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::uit::recommender_frontend::deployment').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
