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
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { [
          'include ::apt',
          'Apt::Source <| |>',
          'Apt::Ppa <| |>',
        ] }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::apt::keys') }

        include_examples 'apt repositories', 'cultuurnet-tools'
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
          context "in the testing environment" do
            let(:environment) { 'testing' }

            it { is_expected.not_to contain_apt__ppa('ppa:deadsnakes/ppa') }

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

            it { is_expected.to contain_apt__source('publiq-prototypes').with(
              'location' => 'https://apt.publiq.be/publiq-prototypes-testing',
              'repos'    => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('publiq-infrastructure').with(
              'location' => 'https://apt.publiq.be/publiq-infrastructure-testing',
              'repos'    => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('publiq-appconfig').with(
              'location' => 'https://apt.publiq.be/publiq-appconfig-testing',
              'repos'    => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'  => 'trusty'
            ) }
          end

        when '16.04'
          context "in the acceptance environment" do
            let(:environment) { 'acceptance' }

            it { is_expected.not_to contain_apt__ppa('ppa:deadsnakes/ppa') }

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
              'release'  => 'xenial'
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

            it { is_expected.to contain_apt__source('docker').with(
              'location'     => 'https://apt.publiq.be/docker-acceptance',
              'ensure'       => 'present',
              'repos'        => 'stable',
              'architecture' => 'amd64',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uit-mail-subscriptions').with(
              'location'     => 'https://apt.publiq.be/uit-mail-subscriptions-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uit-frontend').with(
              'location'     => 'https://apt.publiq.be/uit-frontend-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uit-api').with(
              'location'     => 'https://apt.publiq.be/uit-api-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uit-cms').with(
              'location'     => 'https://apt.publiq.be/uit-cms-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitid-app').with(
              'location'     => 'https://apt.publiq.be/uitid-app-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitid-frontend').with(
              'location'     => 'https://apt.publiq.be/uitid-frontend-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitid-api').with(
              'location'     => 'https://apt.publiq.be/uitid-api-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('widgetbeheer-frontend').with(
              'location'     => 'https://apt.publiq.be/widgetbeheer-frontend-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('projectaanvraag-api').with(
              'location'     => 'https://apt.publiq.be/projectaanvraag-api-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('projectaanvraag-frontend').with(
              'location'     => 'https://apt.publiq.be/projectaanvraag-frontend-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitpas-app').with(
              'location'     => 'https://apt.publiq.be/uitpas-app-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitpas-website-api').with(
              'location'     => 'https://apt.publiq.be/uitpas-website-api-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitpas-website-frontend').with(
              'location'     => 'https://apt.publiq.be/uitpas-website-frontend-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('newrelic').with(
              'location'     => 'https://apt.publiq.be/newrelic-acceptance',
              'ensure'       => 'present',
              'repos'        => 'non-free',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('newrelic-infra').with(
              'location'     => 'https://apt.publiq.be/newrelic-infra-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('elastic-8.x').with(
              'location'     => 'https://apt.publiq.be/elastic-8.x-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('nodejs_16').with(
              'location'     => 'https://apt.publiq.be/nodejs_16-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('curator-articlelinker').with(
              'location'     => 'https://apt.publiq.be/curator-articlelinker-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitpas-balie-frontend').with(
              'location'     => 'https://apt.publiq.be/uitpas-balie-frontend-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitpas-balie-api').with(
              'location'     => 'https://apt.publiq.be/uitpas-balie-api-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-tools').with(
              'location'     => 'https://apt.publiq.be/publiq-tools-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-tools-xenial').with(
              'location'     => 'https://apt.publiq.be/publiq-tools-xenial-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-versions').with(
              'location'     => 'https://apt.publiq.be/publiq-versions-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-prototypes').with(
              'location'     => 'https://apt.publiq.be/publiq-prototypes-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-infrastructure').with(
              'location'     => 'https://apt.publiq.be/publiq-infrastructure-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-appconfig').with(
              'location'     => 'https://apt.publiq.be/publiq-appconfig-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-nodejs-14').with(
              'location'     => 'https://apt.publiq.be/publiq-nodejs-14-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-nodejs-16').with(
              'location'     => 'https://apt.publiq.be/publiq-nodejs-16-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }
          end

          context "in the production environment" do
            let(:environment) { 'production' }

            it { is_expected.to contain_apt__source('museumpas-mspotm').with(
              'location'     => 'https://apt.publiq.be/museumpas-mspotm-production',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }
          end

        when '18.04'
          context "in the testing environment" do
            let(:environment) { 'testing' }

            it { is_expected.to contain_apt__ppa('ppa:deadsnakes/ppa') }

            it { is_expected.to contain_apt__source('publiq-nodejs-14').with(
              'location'     => 'https://apt.publiq.be/publiq-nodejs-14-testing',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'bionic'
            ) }

            it { is_expected.to contain_apt__source('publiq-nodejs-16').with(
              'location'     => 'https://apt.publiq.be/publiq-nodejs-16-testing',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'bionic'
            ) }
          end
        end
      end
    end
  end
end
