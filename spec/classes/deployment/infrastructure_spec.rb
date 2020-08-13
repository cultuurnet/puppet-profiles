require 'spec_helper'

describe 'profiles::deployment::infrastructure' do
  include_examples 'operating system support', 'profiles::deployment::infrastructure'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let (:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::apt_keys') }

      it { is_expected.to contain_apt__source('publiq-infrastructure').with(
        'location' => 'http://apt.publiq.be/infrastructure-production',
        'ensure'   => 'present',
        'repos'    => 'main',
        'include'  => {
           'deb' => 'true',
           'src' => 'false'
        }
      ) }

      it { is_expected.to contain_apt__source('publiq-infrastructure').that_requires('Class[profiles::apt_keys]') }
      it { is_expected.to contain_profiles__apt__update('publiq-infrastructure').that_requires('Apt::Source[publiq-infrastructure]') }

      it { is_expected.to contain_package('infrastructure-publiq').with(
        'ensure' => 'latest'
      ) }

      it { is_expected.to contain_exec('puppetserver_environment_cache_clear').with(
        'command'     => 'curl -i -k --fail -X DELETE https://localhost:8140/puppet-admin-api/v1/environment-cache',
        'path'        => [ '/usr/local/bin', '/usr/bin', '/bin' ],
        'refreshonly' => true,
      ) }

      it { is_expected.to contain_package('infrastructure-publiq').that_requires('Profiles::Apt::Update[publiq-infrastructure]') }
      it { is_expected.to contain_package('infrastructure-publiq').that_notifies('Exec[puppetserver_environment_cache_clear]') }

      case facts[:os]['release']['major']
      when '14.04'
        let (:facts) { facts }

        it { is_expected.to contain_apt__source('publiq-infrastructure').with(
          'release' => 'trusty'
        ) }

      when '16.04'
        let (:facts) { facts }

        it { is_expected.to contain_apt__source('publiq-infrastructure').with(
          'release' => 'xenial'
        ) }
      end
    end
  end
end
