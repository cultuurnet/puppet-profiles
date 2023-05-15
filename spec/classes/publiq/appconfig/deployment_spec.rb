require 'spec_helper'

describe 'profiles::publiq::appconfig::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::puppet::puppetserver::cache_clear') }

        it { is_expected.to contain_apt__source('publiq-appconfig') }

        it { is_expected.to contain_package('publiq-appconfig').with(
          'ensure' => 'latest'
        ) }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::appconfig::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::appconfig::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end

        it { is_expected.to contain_package('publiq-appconfig').that_requires('Apt::Source[publiq-appconfig]') }
        it { is_expected.to contain_package('publiq-appconfig').that_notifies('Class[profiles::puppet::puppetserver::cache_clear]') }
        it { is_expected.to contain_package('publiq-appconfig').that_notifies('Profiles::Deployment::Versions[profiles::publiq::appconfig::deployment]') }
        it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::appconfig::deployment').that_requires('Class[profiles::puppet::puppetserver::cache_clear]') }
      end

      context "with version => 1.2.3 and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'version' => '1.2.3',
          'puppetdb_url'    => 'http://example.com:8000'
        } }

        it { is_expected.to contain_package('publiq-appconfig').with(
          'ensure' => '1.2.3'
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::appconfig::deployment').with(
          'puppetdb_url'    => 'http://example.com:8000'
        ) }
      end
    end
  end
end
