require 'spec_helper'

describe 'profiles::publiq::infrastructure::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::puppetserver::cache_clear') }

        it { is_expected.to contain_apt__source('publiq-infrastructure') }

        it { is_expected.to contain_package('publiq-infrastructure').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::infrastructure::deployment').with(
          'project'      => 'publiq',
          'packages'     => 'publiq-infrastructure',
          'puppetdb_url' => nil
        ) }

        it { is_expected.to contain_package('publiq-infrastructure').that_requires('Apt::Source[publiq-infrastructure]') }
        it { is_expected.to contain_package('publiq-infrastructure').that_notifies('Class[profiles::puppetserver::cache_clear]') }
        it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::infrastructure::deployment').that_requires('Class[profiles::puppetserver::cache_clear]') }
      end

      context "with version => 1.2.3 and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'version'      => '1.2.3',
          'puppetdb_url' => 'http://example.com:8000'
        } }

        it { is_expected.to contain_package('publiq-infrastructure').with(
          'ensure' => '1.2.3'
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::publiq::infrastructure::deployment').with(
          'project'         => 'publiq',
          'packages'        => 'publiq-infrastructure',
          'puppetdb_url'    => 'http://example.com:8000'
        ) }
      end
    end
  end
end