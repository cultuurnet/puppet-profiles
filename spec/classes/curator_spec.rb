require 'spec_helper'

describe 'profiles::curator' do
  let(:pre_condition) { 'include ::profiles' }

  include_examples 'operating system support', 'profiles::curator'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      context "with all virtual resources realized" do
        let(:pre_condition) { 'include ::profiles; Apt::Source <| |>' }

        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

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
          )
          }
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
          )
          }
        end
      end
    end
  end
end
