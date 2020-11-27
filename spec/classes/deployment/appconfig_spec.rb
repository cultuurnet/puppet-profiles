require 'spec_helper'

describe 'profiles::deployment::appconfig' do
  include_examples 'operating system support', 'profiles::deployment::appconfig'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let (:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::apt::keys') }
      it { is_expected.to contain_class('profiles::puppetserver::cache_clear') }

      it { is_expected.to contain_apt__source('publiq-appconfig').with(
        'location' => 'https://apt.publiq.be/appconfig-production',
        'ensure'   => 'present',
        'repos'    => 'main',
        'include'  => {
           'deb' => 'true',
           'src' => 'false'
        }
      ) }

      it { is_expected.to contain_apt__source('publiq-appconfig').that_requires('Class[profiles::apt::keys]') }
      it { is_expected.to contain_profiles__apt__update('publiq-appconfig') }

      it { is_expected.to contain_package('appconfig-publiq').that_requires('Profiles::Apt::Update[publiq-appconfig]') }
      it { is_expected.to contain_package('appconfig-publiq').that_notifies('Class[profiles::puppetserver::cache_clear]') }
      it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::appconfig').that_requires('Class[profiles::puppetserver::cache_clear]') }

      case facts[:os]['release']['major']
      when '14.04'
        let (:facts) { facts }

        it { is_expected.to contain_apt__source('publiq-appconfig').with(
          'release' => 'trusty'
        ) }

      when '16.04'
        let (:facts) { facts }

        it { is_expected.to contain_apt__source('publiq-appconfig').with(
          'release' => 'xenial'
        ) }
      end

      context "without parameters" do
        let (:params) { {} }

        it { is_expected.to contain_package('appconfig-publiq').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::appconfig').with(
          'project'      => 'appconfig',
          'packages'     => 'appconfig-publiq',
          'puppetdb_url' => nil
        ) }
      end

      context "with package_version => 1.2.3 and puppetdb_url => http://example.com:8000" do
        let (:params) { {
          'package_version' => '1.2.3',
          'puppetdb_url'    => 'http://example.com:8000'
        } }

        it { is_expected.to contain_package('appconfig-publiq').with(
          'ensure' => '1.2.3'
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::appconfig').with(
          'project'         => 'appconfig',
          'packages'        => 'appconfig-publiq',
          'destination_dir' => '/var/run',
          'puppetdb_url'    => 'http://example.com:8000'
        ) }
      end
    end
  end
end
