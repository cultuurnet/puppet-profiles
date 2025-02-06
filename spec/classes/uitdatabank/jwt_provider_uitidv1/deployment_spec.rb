describe 'profiles::uitdatabank::jwt_provider_uitidv1::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => /tmp/config.yml, private_key_source => /tmp/private.pem and public_key_source => /tmp/public.pem" do
        let(:params) { {
          'config_source'      => '/tmp/config.yml',
          'private_key_source' => '/tmp/private.pem',
          'public_key_source'  => '/tmp/public.pem'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::jwt_provider_uitidv1::deployment').with(
          'config_source'      => '/tmp/config.yml',
          'private_key_source' => '/tmp/private.pem',
          'public_key_source'  => '/tmp/public.pem',
          'version'            => 'latest',
          'repository'         => 'uitdatabank-jwt-provider-uitidv1',
          'puppetdb_url'       => nil
        ) }

        it { is_expected.to contain_apt__source('uitdatabank-jwt-provider-uitidv1') }
        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_package('uitdatabank-jwt-provider-uitidv1').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-config').with(
          'ensure' => 'file',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'path'   => '/var/www/jwt-provider-uitidv1/config.yml',
          'source' => '/tmp/config.yml'
        ) }

        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-private-key').with(
          'ensure' => 'file',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'path'   => '/var/www/jwt-provider-uitidv1/private.pem',
          'source' => '/tmp/private.pem'
        ) }

        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-public-key').with(
          'ensure' => 'file',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'path'   => '/var/www/jwt-provider-uitidv1/public.pem',
          'source' => '/tmp/public.pem'
        ) }

        it { is_expected.to contain_profiles__php__fpm_service_alias('uitdatabank-jwt-provider-uitidv1') }

        it { is_expected.to contain_service('uitdatabank-jwt-provider-uitidv1').with(
          'hasstatus'  => true,
          'hasrestart' => true,
          'restart'    => '/usr/bin/systemctl reload uitdatabank-jwt-provider-uitidv1'
        ) }

        it { is_expected.to contain_package('uitdatabank-jwt-provider-uitidv1').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::jwt_provider_uitidv1::deployment]') }
        it { is_expected.to contain_package('uitdatabank-jwt-provider-uitidv1').that_requires('Apt::Source[uitdatabank-jwt-provider-uitidv1]') }
        it { is_expected.to contain_package('uitdatabank-jwt-provider-uitidv1').that_notifies('Service[uitdatabank-jwt-provider-uitidv1]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-config').that_requires('Package[uitdatabank-jwt-provider-uitidv1]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-config').that_notifies('Service[uitdatabank-jwt-provider-uitidv1]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-private-key').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-private-key').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-private-key').that_requires('Package[uitdatabank-jwt-provider-uitidv1]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-private-key').that_notifies('Service[uitdatabank-jwt-provider-uitidv1]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-public-key').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-public-key').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-public-key').that_requires('Package[uitdatabank-jwt-provider-uitidv1]') }
        it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-public-key').that_notifies('Service[uitdatabank-jwt-provider-uitidv1]') }
        it { is_expected.to contain_service('uitdatabank-jwt-provider-uitidv1').that_requires('Profiles::Php::Fpm_service_alias[uitdatabank-jwt-provider-uitidv1]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::jwt_provider_uitidv1::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::jwt_provider_uitidv1::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context "with config_source => /tmp/myconfig.yml, private_key_source => /tmp/my_private_key.pem, public_key_source => /tmp/my_public_key.pem, version => 1.2.3, repository => myrepo and puppetdb_url => http://puppetdb.example.com:8080" do
        let(:params) { {
          'config_source'      => '/tmp/myconfig.yml',
          'private_key_source' => '/tmp/my_private_key.pem',
          'public_key_source'  => '/tmp/my_public_key.pem',
          'version'            => '1.2.3',
          'repository'         => 'myrepo',
          'puppetdb_url'       => 'http://puppetdb.example.com:8080'
        } }

        context 'with repository myrepo defined' do
          let(:pre_condition) { [
            '@apt::source { "myrepo": location => "http://localhost", release => "focal", repos => "main" }',
          ] }

          it { is_expected.to contain_apt__source('myrepo') }

          it { is_expected.to contain_package('uitdatabank-jwt-provider-uitidv1').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-config').with(
            'source' => '/tmp/myconfig.yml'
          ) }

          it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-private-key').with(
            'source' => '/tmp/my_private_key.pem'
          ) }

          it { is_expected.to contain_file('uitdatabank-jwt-provider-uitidv1-public-key').with(
            'source' => '/tmp/my_public_key.pem'
          ) }

          it { is_expected.to contain_package('uitdatabank-jwt-provider-uitidv1').that_requires('Apt::Source[myrepo]') }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::jwt_provider_uitidv1::deployment').with(
            'puppetdb_url' => 'http://puppetdb.example.com:8080'
          ) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'private_key_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'public_key_source'/) }
      end
    end
  end
end
