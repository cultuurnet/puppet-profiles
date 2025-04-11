describe 'profiles::uitpas::groepspas::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => /mytestconfig' do
        let(:params) { {
          'config_source' => '/mytestconfig'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitpas::groepspas::deployment').with(
          'config_source' => '/mytestconfig',
          'version'       => 'latest',
          'repository'    => 'uitpas-groepspas',
          'puppetdb_url'  => nil
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_apt__source('uitpas-groepspas') }
        it { is_expected.to contain_package('rubygem-angular-config') }
        it { is_expected.to contain_package('uitpas-groepspas').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('uitpas-groepspas-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uitpas-groepspas/config/config.json',
          'source' => '/mytestconfig',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitpas-groepspas-deploy-config').with(
          'ensure' => 'file',
          'path'   => '/usr/local/bin/uitpas-groepspas-deploy-config',
          'source' => 'puppet:///modules/profiles/uitpas/groepspas/angular-deploy-config.rb',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_exec('uitpas-groepspas-deploy-config').with(
          'command'     => 'uitpas-groepspas-deploy-config /var/www/uitpas-groepspas',
          'path'        => ['/usr/local/bin', '/usr/bin', '/bin'],
          'refreshonly' => true
        ) }

        it { is_expected.to contain_package('uitpas-groepspas').that_requires('Apt::Source[uitpas-groepspas]') }
        it { is_expected.to contain_package('uitpas-groepspas').that_requires('Group[www-data]') }
        it { is_expected.to contain_package('uitpas-groepspas').that_requires('User[www-data]') }
        it { is_expected.to contain_package('uitpas-groepspas').that_notifies('Profiles::Deployment::Versions[profiles::uitpas::groepspas::deployment]') }
        it { is_expected.to contain_file('uitpas-groepspas-config').that_requires('Package[uitpas-groepspas]') }
        it { is_expected.to contain_file('uitpas-groepspas-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitpas-groepspas-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitpas-groepspas-deploy-config').that_requires('Package[rubygem-angular-config]') }
        it { is_expected.to contain_exec('uitpas-groepspas-deploy-config').that_subscribes_to('Package[uitpas-groepspas]') }
        it { is_expected.to contain_exec('uitpas-groepspas-deploy-config').that_subscribes_to('File[uitpas-groepspas-config]') }
        it { is_expected.to contain_exec('uitpas-groepspas-deploy-config').that_subscribes_to('File[uitpas-groepspas-deploy-config]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::groepspas::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::groepspas::deployment').with(
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
          it { is_expected.to contain_package('uitpas-groepspas').with(
            'ensure' => '4.5.6'
          ) }

          it { is_expected.to contain_file('uitpas-groepspas-config').with(
            'ensure' => 'file',
            'path'   => '/var/www/uitpas-groepspas/config/config.json',
            'source' => '/foo.json',
            'owner'  => 'www-data',
            'group'  => 'www-data'
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::groepspas::deployment').with(
            'puppetdb_url' => 'http://puppetdb.example.com'
          ) }

          it { is_expected.to contain_package('uitpas-groepspas').that_requires('Apt::Source[myrepo]') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
