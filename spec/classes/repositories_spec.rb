require 'spec_helper'

describe 'profiles::repositories' do
  include_examples 'operating system support', 'profiles::repositories'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      context "with all virtual resources realized" do
        let(:pre_condition) { 'Apt::Source <| |>' }

        case facts[:os]['release']['major']
        when '14.04'
          let (:facts) { facts.merge( { 'os' => { 'distro' => { 'codename' => 'trusty' } } } ) }

          it { is_expected.to compile.with_all_deps }

          context "in the testing environment" do
            let(:environment) { 'testing' }

            it { is_expected.to contain_apt__source('cultuurnet-tools').with(
              'location' => 'http://apt.uitdatabank.be/tools-testing',
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
        when '16.04'
          let (:facts) { facts.merge( { 'os' => { 'distro' => { 'codename' => 'xenial' } } } ) }

          it { is_expected.to compile.with_all_deps }

          context "in the acceptance environment" do
            let(:environment) { 'acceptance' }

            it { is_expected.to contain_apt__source('cultuurnet-tools').with(
              'location' => 'http://apt.uitdatabank.be/tools-acceptance',
              'ensure'  => 'present',
              'repos'   => 'main',
              'include' => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'xenial'
            )
            }
          end
        end
      end
    end
  end
end
