require 'spec_helper'
require 'pp'

describe 'profiles::publiq::infrastructure::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::publiq::infrastructure::deployment').with(
          'version'    => 'latest',
          'repository' => 'publiq-infrastructure'
        ) }

        it { is_expected.to contain_class('profiles::puppet::puppetserver::cache_clear') }

        it { is_expected.to contain_apt__source('publiq-infrastructure') }

        it { is_expected.to contain_package('publiq-infrastructure').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('publiq-infrastructure production environment hiera.yaml').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/code/environments/production/hiera.yaml'
        ) }

        it { is_expected.to contain_file('publiq-infrastructure production environment datadir').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/code/environments/production/data',
          'force'  => true
        ) }

        it { is_expected.to contain_file('publiq-infrastructure acceptance environment environment.conf').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppetlabs/code/environments/acceptance/environment.conf',
          'content' => 'config_version = /etc/puppetlabs/code/get_config_version.sh'
        ) }

        it { is_expected.to contain_file('publiq-infrastructure testing environment environment.conf').with(
          'ensure' => 'file',
          'path'    => '/etc/puppetlabs/code/environments/testing/environment.conf',
          'content' => 'config_version = /etc/puppetlabs/code/get_config_version.sh'
        ) }

        it { is_expected.to contain_file('publiq-infrastructure production environment environment.conf').with(
          'ensure' => 'file',
          'path'    => '/etc/puppetlabs/code/environments/production/environment.conf',
          'content' => 'config_version = /etc/puppetlabs/code/get_config_version.sh'
        ) }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_class('profiles::publiq::infrastructure::deployment').with(
            'puppetdb_url' => nil
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::infrastructure::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_class('profiles::publiq::infrastructure::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::infrastructure::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end

        it { is_expected.to contain_package('publiq-infrastructure').that_requires('Apt::Source[publiq-infrastructure]') }
        it { is_expected.to contain_package('publiq-infrastructure').that_notifies('Class[profiles::puppet::puppetserver::cache_clear]') }
        it { is_expected.to contain_file('publiq-infrastructure production environment hiera.yaml').that_notifies('Class[profiles::puppet::puppetserver::cache_clear]') }
        it { is_expected.to contain_file('publiq-infrastructure production environment datadir').that_notifies('Class[profiles::puppet::puppetserver::cache_clear]') }
        it { is_expected.to contain_file('publiq-infrastructure acceptance environment environment.conf').that_requires('Package[publiq-infrastructure]') }
        it { is_expected.to contain_file('publiq-infrastructure acceptance environment environment.conf').that_notifies('Class[profiles::puppet::puppetserver::cache_clear]') }
        it { is_expected.to contain_file('publiq-infrastructure testing environment environment.conf').that_requires('Package[publiq-infrastructure]') }
        it { is_expected.to contain_file('publiq-infrastructure testing environment environment.conf').that_notifies('Class[profiles::puppet::puppetserver::cache_clear]') }
        it { is_expected.to contain_file('publiq-infrastructure production environment environment.conf').that_requires('Package[publiq-infrastructure]') }
        it { is_expected.to contain_file('publiq-infrastructure production environment environment.conf').that_notifies('Class[profiles::puppet::puppetserver::cache_clear]') }
        it { is_expected.to contain_package('publiq-infrastructure').that_notifies('Profiles::Deployment::Versions[profiles::publiq::infrastructure::deployment]') }
        it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::infrastructure::deployment').that_requires('Class[profiles::puppet::puppetserver::cache_clear]') }
      end

      context "with version => 1.2.3, repository => publiq-infrastructure-legacy and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'version'      => '1.2.3',
          'repository'   => 'publiq-infrastructure-legacy',
          'puppetdb_url' => 'http://example.com:8000'
        } }

        it { is_expected.to contain_apt__source('publiq-infrastructure-legacy') }

        it { is_expected.to contain_package('publiq-infrastructure').with(
          'ensure' => '1.2.3'
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::infrastructure::deployment').with(
          'puppetdb_url'    => 'http://example.com:8000'
        ) }

        it { is_expected.to contain_package('publiq-infrastructure').that_requires('Apt::Source[publiq-infrastructure-legacy]') }
      end
    end
  end
end
