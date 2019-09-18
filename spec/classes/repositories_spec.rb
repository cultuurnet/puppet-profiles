require 'spec_helper'

describe 'profiles::repositories' do
  let(:pre_condition) { 'include ::profiles' }

  include_examples 'operating system support', 'profiles::repositories'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      context "with all virtual resources realized" do
        let(:pre_condition) { 'include ::profiles; Apt::Source <| |>; Profiles::Apt::Update <| |>' }

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

            it { is_expected.to contain_profiles__apt__update('cultuurnet-tools').that_requires('Apt::Source[cultuurnet-tools]') }

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

            it { is_expected.to contain_apt__source('nodejs_8.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_8.x-testing',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'trusty'
            )
            }

            it { is_expected.to contain_apt__source('nodejs_10.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_10.x-testing',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'trusty'
            )
            }

            it { is_expected.to contain_apt__source('elasticsearch').with(
              'location' => 'http://apt.uitdatabank.be/elasticsearch-testing',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'stable'
            )
            }

            it { is_expected.to contain_profiles__apt__update('elasticsearch').that_requires('Apt::Source[elasticsearch]') }

            it { is_expected.to contain_apt__source('php').with(
              'location' => 'http://apt.uitdatabank.be/php-testing',
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

            it { is_expected.to contain_profiles__apt__update('cultuurnet-tools').that_requires('Apt::Source[cultuurnet-tools]') }

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

            it { is_expected.to contain_apt__source('nodejs_8.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_8.x-acceptance',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'xenial'
            )
            }

            it { is_expected.to contain_apt__source('nodejs_10.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_10.x-acceptance',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'trusty'
            )
            }

            it { is_expected.to contain_apt__source('elasticsearch').with(
              'location' => 'http://apt.uitdatabank.be/elasticsearch-acceptance',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'stable'
            )
            }

            it { is_expected.to contain_profiles__apt__update('elasticsearch').that_requires('Apt::Source[elasticsearch]') }
          end
        end
      end
    end
  end
end
