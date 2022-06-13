require 'spec_helper'

describe 'profiles::deployment::prototypes' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::apt::keys') }

      it { is_expected.to contain_apt__source('publiq-prototypes').with(
        'location' => 'https://apt.publiq.be/prototypes-production',
        'ensure'   => 'present',
        'repos'    => 'main',
        'include'  => {
           'deb' => 'true',
           'src' => 'false'
        }
      ) }

      it { is_expected.to contain_apt__source('publiq-prototypes').that_requires('Class[profiles::apt::keys]') }
      it { is_expected.to contain_apt__source('publiq-prototypes') }

      it { is_expected.to contain_package('publiq-prototypes').that_requires('Apt::Source[publiq-prototypes]') }

      case facts[:os]['release']['major']
      when '14.04'
        let(:facts) { facts }

        it { is_expected.to contain_apt__source('publiq-prototypes').with(
          'release' => 'trusty'
        ) }

      when '16.04'
        let(:facts) { facts }

        it { is_expected.to contain_apt__source('publiq-prototypes').with(
          'release' => 'xenial'
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to contain_package('publiq-prototypes').with(
          'ensure' => 'latest'
        ) }
      end

      context "with version => 1.2.3 and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'version'      => '1.2.3',
          'puppetdb_url' => 'http://example.com:8000'
        } }

        it { is_expected.to contain_package('publiq-prototypes').with(
          'ensure' => '1.2.3'
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::prototypes').with(
          'project'         => 'publiq',
          'packages'        => 'publiq-prototypes',
          'destination_dir' => '/var/run',
          'puppetdb_url'    => 'http://example.com:8000'
        ) }
      end
    end
  end
end
