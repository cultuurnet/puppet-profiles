describe 'profiles::uitdatabank::angular_app::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => /mytestconfig' do
        let(:params) { {
          'config_source' => '/mytestconfig'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::angular_app::deployment').with(
          'config_source' => '/mytestconfig',
          'version'       => 'latest',
          'repository'    => 'uitdatabank-angular-app',
          'puppetdb_url'  => nil
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_apt__source('uitdatabank-angular-app') }
        it { is_expected.to contain_package('rubygem-angular-config') }
        it { is_expected.to contain_package('uitdatabank-angular-app').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('uitdatabank-angular-app-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/udb3-angular-app/config.json',
          'source' => '/mytestconfig',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitdatabank-angular-app-deploy-config').with(
          'ensure' => 'file',
          'path'   => '/usr/local/bin/uitdatabank-angular-app-deploy-config',
          'source' => 'puppet:///modules/profiles/uitdatabank/angular_app/angular-deploy-config.rb',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_exec('uitdatabank-angular-app-deploy-config').with(
          'command'     => 'uitdatabank-angular-app-deploy-config /var/www/udb3-angular-app',
          'path'        => ['/usr/local/bin', '/usr/bin', '/bin'],
          'refreshonly' => true
        ) }

        it { is_expected.to contain_package('uitdatabank-angular-app').that_requires('Apt::Source[uitdatabank-angular-app]') }
        it { is_expected.to contain_package('uitdatabank-angular-app').that_requires('Group[www-data]') }
        it { is_expected.to contain_package('uitdatabank-angular-app').that_requires('User[www-data]') }
        it { is_expected.to contain_package('uitdatabank-angular-app').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::angular_app::deployment]') }
        it { is_expected.to contain_file('uitdatabank-angular-app-config').that_requires('Package[uitdatabank-angular-app]') }
        it { is_expected.to contain_file('uitdatabank-angular-app-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-angular-app-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-angular-app-deploy-config').that_requires('Package[rubygem-angular-config]') }
        it { is_expected.to contain_exec('uitdatabank-angular-app-deploy-config').that_subscribes_to('Package[uitdatabank-angular-app]') }
        it { is_expected.to contain_exec('uitdatabank-angular-app-deploy-config').that_subscribes_to('File[uitdatabank-angular-app-config]') }
        it { is_expected.to contain_exec('uitdatabank-angular-app-deploy-config').that_subscribes_to('File[uitdatabank-angular-app-deploy-config]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::angular_app::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::angular_app::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context 'with config_source => /foo.json, version => 4.5.6, repository => myrepo and puppetdb_url => http://puppetdb.example.com' do
        let(:params) { {
          'config_source' => '/foo.json',
          'version'       => '4.5.6',
          'repository'    => 'myrepo',
          'puppetdb_url'  => 'http://puppetdb.example.com'
        } }

        context "with repository myrepo defined" do
          let(:pre_condition) { [
            '@apt::source { "myrepo": location => "http://localhost", release => "focal", repos => "main" }',
          ] }

          it { is_expected.to contain_apt__source('myrepo') }
          it { is_expected.to contain_package('uitdatabank-angular-app').with(
            'ensure' => '4.5.6'
          ) }

          it { is_expected.to contain_file('uitdatabank-angular-app-config').with(
            'ensure' => 'file',
            'path'   => '/var/www/udb3-angular-app/config.json',
            'source' => '/foo.json',
            'owner'  => 'www-data',
            'group'  => 'www-data'
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::angular_app::deployment').with(
            'puppetdb_url' => 'http://puppetdb.example.com'
          ) }

          it { is_expected.to contain_package('uitdatabank-angular-app').that_requires('Apt::Source[myrepo]') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
