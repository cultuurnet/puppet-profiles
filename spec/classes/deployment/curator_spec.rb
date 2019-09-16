require 'spec_helper'

describe 'profiles::deployment::curator' do
  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let (:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Apt::Source <| |>; Profiles::Apt::Update <| |>' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_profiles__apt__update('publiq-curator').that_requires('Apt::Source[publiq-curator]') }

        context "in the testing environment" do
          let(:environment) { 'testing' }

          it { is_expected.to contain_apt__source('publiq-curator').with(
            'location' => 'http://apt.uitdatabank.be/curator-testing',
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

          it { is_expected.to contain_apt__source('publiq-curator').with(
            'location' => 'http://apt.uitdatabank.be/curator-production',
            'ensure'   => 'present',
            'repos'    => 'main',
            'include'  => {
              'deb' => 'true',
              'src' => 'false'
            },
            'release' => 'trusty'
          ) }

          it { is_expected.to contain_profiles__apt__update('publiq-curator').with(

          ) }
        end
      end
    end
  end
end
