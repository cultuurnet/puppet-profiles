require 'spec_helper'

describe 'profiles::apt::repositories' do
  let(:pre_condition) { 'include ::profiles' }

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      context "with all virtual resources realized" do
        let(:pre_condition) { 'Apt::Source <| |>' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::apt::keys') }

        it { is_expected.to contain_apt__source('aptly').with(
          'location' => 'http://repo.aptly.info',
          'ensure'   => 'present',
          'repos'    => 'main',
          'include'  => {
            'deb' => 'true',
            'src' => 'false'
          },
          'release' => 'squeeze'
        )
        }

        it { is_expected.to contain_apt__source('aptly').that_requires('Class[profiles::apt::keys]') }

        case facts[:os]['release']['major']
        when '14.04'
          let(:facts) { facts }

          context "in the testing environment" do
            let(:environment) { 'testing' }

            it { is_expected.to contain_apt__source('cultuurnet-tools').with(
              'location' => 'http://apt.uitdatabank.be/tools-legacy-testing',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'trusty'
            )
            }

            it { is_expected.to contain_apt__source('cultuurnet-tools').that_requires('Class[profiles::apt::keys]') }

            it { is_expected.to contain_apt__source('php').with(
              'location' => 'http://apt.uitdatabank.be/php-legacy-testing',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'trusty'
            )
            }

            it { is_expected.to contain_apt__source('php').that_requires('Class[profiles::apt::keys]') }

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

            it { is_expected.to contain_apt__source('rabbitmq').that_requires('Class[profiles::apt::keys]') }

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

            it { is_expected.to contain_apt__source('nodejs_10.x').that_requires('Class[profiles::apt::keys]') }

            it { is_expected.to contain_apt__source('nodejs_12.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_12.x-testing',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'trusty'
            )
            }

            it { is_expected.to contain_apt__source('nodejs_12.x').that_requires('Class[profiles::apt::keys]') }

            it { is_expected.to contain_apt__source('nodejs_14.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_14.x-testing',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'trusty'
            )
            }

            it { is_expected.to contain_apt__source('nodejs_14.x').that_requires('Class[profiles::apt::keys]') }

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

            it { is_expected.to contain_apt__source('elasticsearch').that_requires('Class[profiles::apt::keys]') }

            it { is_expected.to contain_apt__source('yarn').with(
              'location' => 'http://apt.uitdatabank.be/yarn-testing',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'stable'
            )
            }

            it { is_expected.to contain_apt__source('yarn').that_requires('Class[profiles::apt::keys]') }
          end

        when '16.04'
          let(:facts) { facts }

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

            it { is_expected.to contain_apt__source('cultuurnet-tools').that_requires('Class[profiles::apt::keys]') }

            it { is_expected.to contain_apt__source('php').with(
              'location' => 'http://apt.uitdatabank.be/php-acceptance',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'xenial'
            )
            }

            it { is_expected.to contain_apt__source('php').that_requires('Class[profiles::apt::keys]') }

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

            it { is_expected.to contain_apt__source('rabbitmq').that_requires('Class[profiles::apt::keys]') }

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

            it { is_expected.to contain_apt__source('nodejs_10.x').that_requires('Class[profiles::apt::keys]') }

            it { is_expected.to contain_apt__source('nodejs_12.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_12.x-acceptance',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'trusty'
            )
            }

            it { is_expected.to contain_apt__source('nodejs_12.x').that_requires('Class[profiles::apt::keys]') }

            it { is_expected.to contain_apt__source('nodejs_14.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_14.x-acceptance',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'trusty'
            )
            }

            it { is_expected.to contain_apt__source('nodejs_14.x').that_requires('Class[profiles::apt::keys]') }

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

            it { is_expected.to contain_apt__source('elasticsearch').that_requires('Class[profiles::apt::keys]') }

            it { is_expected.to contain_apt__source('yarn').with(
              'location' => 'http://apt.uitdatabank.be/yarn-acceptance',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'stable'
            )
            }

            it { is_expected.to contain_apt__source('yarn').that_requires('Class[profiles::apt::keys]') }
          end
        end
      end
    end
  end
end
