require 'spec_helper'

describe 'profiles::repositories' do
  let(:pre_condition) { 'include ::profiles' }

  include_examples 'operating system support', 'profiles::repositories'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      context "with all virtual resources realized" do
        let(:pre_condition) { 'include ::profiles; Apt::Source <| |>' }

        case facts[:os]['release']['major']
        when '14.04'
          let (:facts) { facts }

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

            it { is_expected.to contain_apt__source('rabbitmq').with(
              'location' => 'http://apt.uitdatabank.be/rabbitmq-testing',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'testing'
            )
            }
          end

        when '16.04'
          let (:facts) { facts }

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

            it { is_expected.to contain_apt__source('rabbitmq').with(
              'location' => 'http://apt.uitdatabank.be/rabbitmq-acceptance',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'testing'
            )
            }
          end
        end
      end
    end
  end
end
