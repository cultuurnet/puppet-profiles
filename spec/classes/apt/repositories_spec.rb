require 'spec_helper'

RSpec.shared_examples "apt repositories" do |repository|
  it { is_expected.to contain_apt__source(repository).with(
    'ensure'  => 'present',
    'include' => {
      'deb' => 'true',
      'src' => 'false'
    },
  ) }

  it { is_expected.to contain_apt__source(repository).that_requires('Class[profiles::apt::keys]') }
end

describe 'profiles::apt::repositories' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      context "with all virtual resources realized" do
        let(:pre_condition) { 'Apt::Source <| |>' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::apt::keys') }

        include_examples 'apt repositories', 'cultuurnet-tools'
        include_examples 'apt repositories', 'php'
        include_examples 'apt repositories', 'rabbitmq'
        include_examples 'apt repositories', 'nodejs_10.x'
        include_examples 'apt repositories', 'nodejs_12.x'
        include_examples 'apt repositories', 'nodejs_14.x'
        include_examples 'apt repositories', 'elasticsearch'
        include_examples 'apt repositories', 'yarn'
        include_examples 'apt repositories', 'erlang'
        include_examples 'apt repositories', 'publiq-jenkins'
        include_examples 'apt repositories', 'aptly'

        it { is_expected.to contain_apt__source('aptly').with(
          'location' => 'http://repo.aptly.info',
          'repos'    => 'main',
          'release' => 'squeeze'
        ) }

        case facts[:os]['release']['major']
        when '14.04'
          let(:facts) { facts }

          context "in the testing environment" do
            let(:environment) { 'testing' }

            it { is_expected.to contain_apt__source('cultuurnet-tools').with(
              'location' => 'http://apt.uitdatabank.be/tools-legacy-testing',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('php').with(
              'location' => 'http://apt.uitdatabank.be/php-legacy-testing',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('rabbitmq').with(
              'location' => 'http://apt.uitdatabank.be/rabbitmq-testing',
              'repos'    => 'main',
              'release'  => 'testing'
            ) }

            it { is_expected.to contain_apt__source('nodejs_10.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_10.x-testing',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('nodejs_12.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_12.x-testing',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('nodejs_14.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_14.x-testing',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('elasticsearch').with(
              'location' => 'http://apt.uitdatabank.be/elasticsearch-testing',
              'repos'    => 'main',
              'release'  => 'stable'
            ) }

            it { is_expected.to contain_apt__source('yarn').with(
              'location' => 'http://apt.uitdatabank.be/yarn-testing',
              'repos'    => 'main',
              'release'  => 'stable'
            ) }

            it { is_expected.to contain_apt__source('erlang').with(
              'location' => 'http://apt.uitdatabank.be/erlang-testing',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('publiq-jenkins').with(
              'location' => 'http://apt.uitdatabank.be/jenkins-testing',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }
          end

        when '16.04'
          let(:facts) { facts }

          context "in the acceptance environment" do
            let(:environment) { 'acceptance' }

            it { is_expected.to contain_apt__source('cultuurnet-tools').with(
              'location' => 'http://apt.uitdatabank.be/tools-acceptance',
              'repos'    => 'main',
              'release'  => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('php').with(
              'location' => 'http://apt.uitdatabank.be/php-acceptance',
              'repos'    => 'main',
              'release'  => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('rabbitmq').with(
              'location' => 'http://apt.uitdatabank.be/rabbitmq-acceptance',
              'repos'    => 'main',
              'release'  => 'testing'
            ) }

            it { is_expected.to contain_apt__source('nodejs_10.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_10.x-acceptance',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('nodejs_12.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_12.x-acceptance',
              'repos'    => 'main',
              'release'  => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('nodejs_14.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_14.x-acceptance',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('elasticsearch').with(
              'location' => 'http://apt.uitdatabank.be/elasticsearch-acceptance',
              'repos'    => 'main',
              'release'  => 'stable'
            ) }

            it { is_expected.to contain_apt__source('yarn').with(
              'location' => 'http://apt.uitdatabank.be/yarn-acceptance',
              'repos'    => 'main',
              'release'  => 'stable'
            ) }

            it { is_expected.to contain_apt__source('erlang').with(
              'location' => 'http://apt.uitdatabank.be/erlang-acceptance',
              'repos'    => 'main',
              'release'  => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-jenkins').with(
              'location' => 'http://apt.uitdatabank.be/jenkins-acceptance',
              'repos'    => 'main',
              'release'  => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('nodejs_16.x').with(
              'location' => 'http://apt.uitdatabank.be/nodejs_16.x-acceptance',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'xenial'
            ) }
          end
        end
      end
    end
  end
end
