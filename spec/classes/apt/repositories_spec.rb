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

            it { is_expected.to contain_apt__source('erlang').with(
              'location' => 'http://apt.uitdatabank.be/erlang-testing',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('publiq-jenkins').with(
              'location' => 'https://apt.publiq.be/publiq-jenkins-testing',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('cultuurnet-omd').with(
              'location' => 'http://apt.uitdatabank.be/omd-testing',
              'repos'    => 'main',
              'release'  => 'trusty'
            ) }

            it { is_expected.to contain_apt__source('cultuurnet-udb3').with(
              'location' => 'http://apt.uitdatabank.be/udb3-testing',
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

            it { is_expected.to contain_apt__source('publiq-infrastructure-legacy').with(
              'location' => 'https://apt.publiq.be/publiq-infrastructure-legacy-testing',
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

            it { is_expected.to contain_apt__source('erlang').with(
              'location' => 'http://apt.uitdatabank.be/erlang-acceptance',
              'repos'    => 'main',
              'release'  => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-jenkins').with(
              'location' => 'https://apt.publiq.be/publiq-jenkins-acceptance',
              'repos'    => 'main',
              'release'  => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('cultuurnet-omd').with(
              'location' => 'http://apt.uitdatabank.be/omd-acceptance',
              'repos'    => 'main',
              'release'  => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('cultuurnet-udb3').with(
              'location' => 'http://apt.uitdatabank.be/udb3-acceptance',
              'repos'    => 'main',
              'release'  => 'xenial'
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

            it { is_expected.to contain_apt__source('uit-notifications').with(
              'location'     => 'https://apt.publiq.be/uit-notifications-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uit-recommender-frontend').with(
              'location'     => 'https://apt.publiq.be/uit-recommender-frontend-acceptance',
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

            it { is_expected.to contain_apt__source('uit-frontend-nuxt3').with(
              'location'     => 'https://apt.publiq.be/uit-frontend-nuxt3-acceptance',
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

            it { is_expected.to contain_apt__source('uitpas-groepspas-frontend').with(
              'location'     => 'https://apt.publiq.be/uitpas-groepspas-frontend-acceptance',
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
              'location'     => 'https://apt.publiq.be/newrelic-infra-xenial-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('elastic-5.x').with(
              'location'     => 'https://apt.publiq.be/elastic-5.x-acceptance',
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

            it { is_expected.to contain_apt__source('uitdatabank-angular-app').with(
              'location'     => 'https://apt.publiq.be/uitdatabank-angular-app-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitdatabank-newsletter-api').with(
              'location'     => 'https://apt.publiq.be/uitdatabank-newsletter-api-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitdatabank-search-api').with(
              'location'     => 'https://apt.publiq.be/uitdatabank-search-api-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitdatabank-geojson-data').with(
              'location'     => 'https://apt.publiq.be/uitdatabank-geojson-data-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitdatabank-frontend').with(
              'location'     => 'https://apt.publiq.be/uitdatabank-frontend-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitdatabank-jwt-provider').with(
              'location'     => 'https://apt.publiq.be/uitdatabank-jwt-provider-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitdatabank-jwt-provider-uitidv1').with(
              'location'     => 'https://apt.publiq.be/uitdatabank-jwt-provider-uitidv1-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitdatabank-movie-api-fetcher').with(
              'location'     => 'https://apt.publiq.be/uitdatabank-movie-api-fetcher-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitdatabank-entry-api').with(
              'location'     => 'https://apt.publiq.be/uitdatabank-entry-api-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('uitdatabank-websocket-server').with(
              'location'     => 'https://apt.publiq.be/uitdatabank-websocket-server-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('publiq-tools').with(
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

            it { is_expected.to contain_apt__source('publiq-infrastructure-legacy').with(
              'location'     => 'https://apt.publiq.be/publiq-infrastructure-legacy-acceptance',
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

            it { is_expected.to contain_apt__source('nodejs-16').with(
              'location'     => 'https://apt.publiq.be/nodejs-16-acceptance',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'xenial'
            ) }

            it { is_expected.to contain_apt__source('nodejs-18').with(
              'location'     => 'https://apt.publiq.be/nodejs-18-acceptance',
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

            it { is_expected.to contain_apt__source('museumpas-website').with(
              'location'     => 'https://apt.publiq.be/museumpas-website-production',
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

            it { is_expected.to contain_apt__source('publiq-tools').with(
              'location'     => 'https://apt.publiq.be/publiq-tools-bionic-testing',
              'ensure'       => 'present',
              'repos'        => 'main',
              'include'      => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release'      => 'bionic'
            ) }

            it { is_expected.to contain_apt__source('publiq-nodejs-16').with(
              'ensure' => 'absent'
            ) }

            it { is_expected.to contain_apt__source('publiq-nodejs-18').with(
              'ensure' => 'absent'
            ) }
          end

        when '20.04'
          context "in the testing environment" do
            let(:environment) { 'testing' }

            it { is_expected.to contain_apt__source('focal').with(
              'location' => 'https://apt.publiq.be/focal-testing',
              'repos'    => 'main',
              'release'  => 'focal'
            ) }

            it { is_expected.to contain_apt__source('focal-updates').with(
              'location' => 'https://apt.publiq.be/focal-updates-testing',
              'repos'    => 'main',
              'release'  => 'focal'
            ) }

            it { is_expected.to contain_apt__source('focal-security').with(
              'location' => 'https://apt.publiq.be/focal-security-testing',
              'repos'    => 'main',
              'release'  => 'focal'
            ) }

            it { is_expected.to contain_apt__source('focal-backports').with(
              'location' => 'https://apt.publiq.be/focal-backports-testing',
              'repos'    => 'main',
              'release'  => 'focal'
            ) }

            it { is_expected.to contain_apt__source('puppet').with(
              'location' => 'https://apt.publiq.be/puppet-focal-testing',
              'repos'    => 'puppet',
              'release'  => 'focal'
            ) }
          end
        end
      end
    end
  end
end
