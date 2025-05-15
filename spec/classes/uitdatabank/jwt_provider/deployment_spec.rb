describe 'profiles::uitdatabank::jwt_provider::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => appconfig/uitdatabank/udb3-jwtprovider/config.yml" do
        let(:params) { {
          'config_source' => 'appconfig/uitdatabank/udb3-jwtprovider/config.yml'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::jwt_provider::deployment').with(
            'config_source' => 'appconfig/uitdatabank/udb3-jwtprovider/config.yml',
            'version'       => 'latest',
            'repository'    => 'uitdatabank-jwt-provider',
            'puppetdb_url'  => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_apt__source('uitdatabank-jwt-provider') }
          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_package('uitdatabank-jwt-provider').with(
            'ensure' => 'latest'
          ) }

          it { is_expected.to contain_file('uitdatabank-jwt-provider-config').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'path'   => '/var/www/jwt-provider/config.yml'
          ) }

          it { is_expected.to contain_profiles__php__fpm_service_alias('uitdatabank-jwt-provider') }

          it { is_expected.to contain_service('uitdatabank-jwt-provider').with(
            'hasstatus'  => true,
            'hasrestart' => true,
            'restart'    => '/usr/bin/systemctl reload uitdatabank-jwt-provider'
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::jwt_provider::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_package('uitdatabank-jwt-provider').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::jwt_provider::deployment]') }
          it { is_expected.to contain_package('uitdatabank-jwt-provider').that_requires('Apt::Source[uitdatabank-jwt-provider]') }
          it { is_expected.to contain_package('uitdatabank-jwt-provider').that_notifies('Service[uitdatabank-jwt-provider]') }
          it { is_expected.to contain_file('uitdatabank-jwt-provider-config').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-jwt-provider-config').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-jwt-provider-config').that_requires('Package[uitdatabank-jwt-provider]') }
          it { is_expected.to contain_file('uitdatabank-jwt-provider-config').that_notifies('Service[uitdatabank-jwt-provider]') }
          it { is_expected.to contain_service('uitdatabank-jwt-provider').that_requires('Profiles::Php::Fpm_service_alias[uitdatabank-jwt-provider]') }
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::jwt_provider::deployment').with(
            'puppetdb_url' => nil
          ) }
        end
      end

      context "with config_source => appconfig/uitdatabank/udb3-jwtprovider/config.yml, version => 1.2.3, repository => myrepo and puppetdb_url => http://puppetdb.example.com:8080" do
        let(:params) { {
          'config_source' => 'appconfig/uitdatabank/udb3-jwtprovider/config.yml',
          'version'       => '1.2.3',
          'repository'    => 'myrepo',
          'puppetdb_url'  => 'http://puppetdb.example.com:8080'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'with repository myrepo defined' do
            let(:pre_condition) { [
              '@apt::source { "myrepo": location => "http://localhost", release => "focal", repos => "main" }',
            ] }

            it { is_expected.to contain_apt__source('myrepo') }

            it { is_expected.to contain_package('uitdatabank-jwt-provider').with(
              'ensure' => '1.2.3'
            ) }

            it { is_expected.to contain_package('uitdatabank-jwt-provider').that_requires('Apt::Source[myrepo]') }

            it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::jwt_provider::deployment').with(
              'puppetdb_url' => 'http://puppetdb.example.com:8080'
            ) }
          end
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
