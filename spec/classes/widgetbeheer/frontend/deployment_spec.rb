describe 'profiles::widgetbeheer::frontend::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => appconfig/widgetbeheer/frontend/config.json' do
        let(:params) { {
          'config_source' => 'appconfig/widgetbeheer/frontend/config.json'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::widgetbeheer::frontend::deployment').with(
            'config_source' => 'appconfig/widgetbeheer/frontend/config.json',
            'version'       => 'latest',
            'repository'    => 'widgetbeheer-frontend',
            'puppetdb_url'  => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_apt__source('widgetbeheer-frontend') }
          it { is_expected.to contain_package('widgetbeheer-frontend').with(
            'ensure' => 'latest'
          ) }

          it { is_expected.to contain_file('widgetbeheer-frontend-config').with(
            'ensure'  => 'file',
            'path'    => '/var/www/widgetbeheer-frontend/assets/config.json',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "{ \"key\": \"value\" }\n"
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::widgetbeheer::frontend::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_package('widgetbeheer-frontend').that_requires('Apt::Source[widgetbeheer-frontend]') }
          it { is_expected.to contain_package('widgetbeheer-frontend').that_requires('Group[www-data]') }
          it { is_expected.to contain_package('widgetbeheer-frontend').that_requires('User[www-data]') }
          it { is_expected.to contain_package('widgetbeheer-frontend').that_notifies('Profiles::Deployment::Versions[profiles::widgetbeheer::frontend::deployment]') }
          it { is_expected.to contain_file('widgetbeheer-frontend-config').that_requires('Package[widgetbeheer-frontend]') }
          it { is_expected.to contain_file('widgetbeheer-frontend-config').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('widgetbeheer-frontend-config').that_requires('User[www-data]') }
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::widgetbeheer::frontend::deployment').with(
            'puppetdb_url' => nil
          ) }
        end
      end

      context 'with config_source => appconfig/widgetbeheer/frontend/myconfig.json, version => 4.5.6, repository => myrepo and puppetdb_url => http://puppetdb.example.com' do
        let(:params) { {
          'config_source' => 'appconfig/widgetbeheer/frontend/myconfig.json',
          'version'       => '4.5.6',
          'repository'    => 'myrepo',
          'puppetdb_url'  => 'http://puppetdb.example.com'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with repository myrepo defined" do
            let(:pre_condition) { [
              '@apt::source { "myrepo": location => "http://localhost", release => "focal", repos => "main" }',
            ] }

            it { is_expected.to contain_apt__source('myrepo') }
            it { is_expected.to contain_package('widgetbeheer-frontend').with(
              'ensure' => '4.5.6'
            ) }

            it { is_expected.to contain_file('widgetbeheer-frontend-config').with(
              'ensure'  => 'file',
              'path'    => '/var/www/widgetbeheer-frontend/assets/config.json',
              'owner'   => 'www-data',
              'group'   => 'www-data',
              'content' => ''
            ) }

            it { is_expected.to contain_profiles__deployment__versions('profiles::widgetbeheer::frontend::deployment').with(
              'puppetdb_url' => 'http://puppetdb.example.com'
            ) }

            it { is_expected.to contain_package('widgetbeheer-frontend').that_requires('Apt::Source[myrepo]') }
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
