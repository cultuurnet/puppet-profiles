require 'spec_helper'

describe 'profiles::deployment::uit' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Apt::Source <| |>; Profiles::Apt::Update <| |>' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::apt::keys') }

        it { is_expected.to contain_apt__source('publiq-uit').that_requires('Class[profiles::apt::keys]') }
        it { is_expected.to contain_profiles__apt__update('publiq-uit') }

        it { is_expected.to contain_apt__source('publiq-uit').with(
          'ensure'   => 'present',
          'repos'    => 'main',
          'include'  => {
             'deb' => 'true',
             'src' => 'false'
           }
        ) }

        case facts[:os]['release']['major']
        when '14.04'
          let(:facts) { facts }

          it { is_expected.to contain_apt__source('publiq-uit').with(
            'release' => 'trusty'
          ) }

        when '16.04'
          let(:facts) { facts }

          it { is_expected.to contain_apt__source('publiq-uit').with(
            'release' => 'xenial'
          ) }
        end

        context "in the testing environment" do
          let(:environment) { 'testing' }

          it { is_expected.to contain_apt__source('publiq-uit').with(
            'location' => 'http://apt.uitdatabank.be/uit-testing'
          ) }
        end

        context "in the production environment" do
          let(:environment) { 'production' }

          it { is_expected.to contain_apt__source('publiq-uit').with(
            'location' => 'http://apt.uitdatabank.be/uit-production'
          ) }
        end
      end
    end
  end
end
