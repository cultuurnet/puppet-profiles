require 'spec_helper'

RSpec.shared_examples "deployment repositories" do |repository|
  it { is_expected.to contain_apt__source(repository).with(
    'ensure'  => 'present',
    'repos'   => 'main',
    'include' => {
      'deb' => 'true',
      'src' => 'false'
    },
  ) }

  it { is_expected.to contain_apt__source(repository).that_requires('Class[profiles::apt::keys]') }
end

describe 'profiles::deployment::repositories' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { [
          'include ::apt',
          'Apt::Source <| |>'
        ] }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::apt::keys') }

        include_examples 'deployment repositories', 'museumpas-mspotm'
        include_examples 'deployment repositories', 'publiq-uitidv2'
        include_examples 'deployment repositories', 'publiq-uitpasbe'
        include_examples 'deployment repositories', 'cultuurnet-search'

        case facts[:os]['release']['major']
        when '14.04'
          context "in the testing environment" do
            let(:environment) { 'testing' }

            it { is_expected.to contain_apt__source('museumpas-mspotm').with(
              'location' => 'http://apt.uitdatabank.be/mspotm-testing',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('publiq-uitidv2').with(
              'location' => 'http://apt.uitdatabank.be/uitidv2-testing',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('publiq-uitpasbe').with(
              'location' => 'http://apt.uitdatabank.be/uitpas.be-testing',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('cultuurnet-search').with(
              'location' => 'http://apt.uitdatabank.be/search-testing',
              'release'  => 'trusty'
            ) }
          end

        when '16.04'
          context "in the acceptance environment" do
            let(:environment) { 'acceptance' }

            it { is_expected.to contain_apt__source('publiq-uitidv2').with(
              'location' => 'http://apt.uitdatabank.be/uitidv2-acceptance',
              'release'  => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-uitpasbe').with(
              'location' => 'http://apt.uitdatabank.be/uitpas.be-acceptance',
              'release'  => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('cultuurnet-search').with(
              'location' => 'http://apt.uitdatabank.be/search-acceptance',
              'release'  => 'xenial'
            ) }
          end
        end
      end
    end
  end
end
