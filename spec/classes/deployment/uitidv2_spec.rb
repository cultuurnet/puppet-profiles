require 'spec_helper'

describe 'profiles::deployment::uitidv2' do
  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let (:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Apt::Source <| |>; Profiles::Apt::Update <| |>' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::apt::keys') }

        it { is_expected.to contain_apt__source('publiq-uitidv2').that_requires('Class[profiles::apt::keys]') }
        it { is_expected.to contain_profiles__apt__update('publiq-uitidv2') }

        context "in the testing environment" do
          let(:environment) { 'testing' }

          it { is_expected.to contain_apt__source('publiq-uitidv2').with(
            'location' => 'http://apt.uitdatabank.be/uitidv2-testing',
            'ensure'   => 'present',
            'repos'    => 'main',
            'include'  => {
              'deb' => 'true',
              'src' => 'false'
            },
            'release' => 'trusty'
          ) }
        end

        context "in the production environment" do
          let(:environment) { 'production' }

          it { is_expected.to contain_apt__source('publiq-uitidv2').with(
            'location' => 'http://apt.uitdatabank.be/uitidv2-production',
            'ensure'   => 'present',
            'repos'    => 'main',
            'include'  => {
              'deb' => 'true',
              'src' => 'false'
            },
            'release' => 'trusty'
          ) }
        end
      end
    end
  end
end
