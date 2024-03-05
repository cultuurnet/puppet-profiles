describe 'profiles::uitpas::balie::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => /foo" do
        let(:params) { {
          'config_source' => '/foo'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitpas::balie::deployment').with(
          'config_source'     => '/foo',
          'maximum_heap_size' => 512,
          'version'           => 'latest',
          'repository'        => 'uitpas-balie',
          'service_status'    => 'running',
          'service_address'   => '127.0.0.1',
          'service_port'      => 4000,
          'puppetdb_url'      => nil
        ) }

        it { is_expected.to contain_apt__source('uitpas-balie') }
        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_package('uitpas-balie').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uitpas-balie').that_notifies('Profiles::Deployment::Versions[profiles::uitpas::balie::deployment]') }
        it { is_expected.to contain_package('uitpas-balie').that_requires('Apt::Source[uitpas-balie]') }

        it { is_expected.to contain_file('uitpas-balie-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uitpas-balie/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitpas-balie-config').that_requires('Package[uitpas-balie]') }

        it { is_expected.to contain_file('uitpas-balie-service-defaults').with(
          'ensure' => 'file',
          'path'   => '/etc/default/uitpas-balie',
          'owner'  => 'root',
          'group'  => 'root'
        ) }

        it { is_expected.to contain_file('uitpas-balie-service-defaults').with_content(/^NEXT_HOST=127.0.0.1$/) }
        it { is_expected.to contain_file('uitpas-balie-service-defaults').with_content(/^NEXT_PORT=4000$/) }
        it { is_expected.to contain_file('uitpas-balie-service-defaults').with_content(/^NODE_OPTIONS=--max_old_space_size=512$/) }

        it { is_expected.to contain_service('uitpas-balie').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_package('uitpas-balie').that_notifies('Service[uitpas-balie]') }
        it { is_expected.to contain_file('uitpas-balie-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitpas-balie-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitpas-balie-config').that_notifies('Service[uitpas-balie]') }
        it { is_expected.to contain_file('uitpas-balie-service-defaults').that_notifies('Service[uitpas-balie]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::balie::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::balie::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context "with config_source => /bar, maximum_heap_size => 1024, service_address => 0.0.0.0, service_port => 3456, version => 1.2.3, repository => uit-frontend-exotic, service_status => stopped and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'config_source'     => '/bar',
          'version'           => '1.2.3',
          'maximum_heap_size' => 1024,
          'repository'        => 'uitpas-balie-exotic',
          'service_status'    => 'stopped',
          'service_address'   => '0.0.0.0',
          'service_port'      => 3456,
          'puppetdb_url'      => 'http://example.com:8000'
        } }

        context "with repository uitpas-balie-exotic defined" do
          let(:pre_condition) { '@apt::source { "uitpas-balie-exotic": location => "http://localhost", release => "focal", repos => "main" }' }

          it { is_expected.to contain_apt__source('uitpas-balie-exotic') }

          it { is_expected.to contain_file('uitpas-balie-config').with(
            'source' => '/bar',
          ) }

          it { is_expected.to contain_file('uitpas-balie-service-defaults').with_content(/^NEXT_HOST=0.0.0.0$/) }
          it { is_expected.to contain_file('uitpas-balie-service-defaults').with_content(/^NEXT_PORT=3456$/) }
          it { is_expected.to contain_file('uitpas-balie-service-defaults').with_content(/^NODE_OPTIONS=--max_old_space_size=1024$/) }

          it { is_expected.to contain_package('uitpas-balie').with( 'ensure' => '1.2.3') }

          it { is_expected.to contain_service('uitpas-balie').with(
            'ensure'    => 'stopped',
            'enable'    => false
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::balie::deployment').with(
            'puppetdb_url' => 'http://example.com:8000'
          ) }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
