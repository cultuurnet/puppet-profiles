require 'spec_helper'

describe 'profiles::jenkins::repositories' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Apt::Source <| |>; Profiles::Apt::Update <| |>' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::apt::keys') }

        it { is_expected.to contain_apt__source('publiq-jenkins').that_requires('Class[profiles::apt::keys]') }

        it { is_expected.to contain_apt__source('publiq-jenkins').with(
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

          it { is_expected.to contain_apt__source('publiq-jenkins').with(
            'release' => 'trusty'
          ) }

        when '16.04'
          let(:facts) { facts }

          it { is_expected.to contain_apt__source('publiq-jenkins').with(
            'release' => 'xenial'
          ) }
        end

        context "in the testing environment" do
          let(:environment) { 'testing' }

          it { is_expected.to contain_apt__source('publiq-jenkins').with(
            'location' => 'http://apt.uitdatabank.be/jenkins-testing'
          ) }
        end

        context "in the production environment" do
          let(:environment) { 'production' }

          it { is_expected.to contain_apt__source('publiq-jenkins').with(
            'location' => 'http://apt.uitdatabank.be/jenkins-production'
          ) }
        end
      end
    end
  end
end
