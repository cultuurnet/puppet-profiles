RSpec.shared_examples "apt repositories" do |repository, params|
  it { is_expected.to contain_apt__source(repository).with(
    'location' => params[:location],
    'ensure'   => 'present',
    'include'  => {
                    'deb' => 'true',
                    'src' => 'false'
                  },
    'repos'    => params[:repos],
    'release'  => params[:release]
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

        it { is_expected.to contain_apt__source('aptly').with(
          'location' => 'http://repo.aptly.info',
          'repos'    => 'main',
          'release' => 'squeeze'
        ) }

        case facts[:os]['release']['major']
        when '20.04'
          context "in the testing environment" do
            let(:environment) { 'testing' }

            include_examples 'apt repositories', 'focal', { :location => 'https://apt.publiq.be/focal-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'focal-updates', { :location => 'https://apt.publiq.be/focal-updates-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'focal-security', { :location => 'https://apt.publiq.be/focal-security-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'focal-backports', { :location => 'https://apt.publiq.be/focal-backports-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'puppet', { :location => 'https://apt.publiq.be/puppet-focal-testing', :repos => 'puppet', :release => 'focal' }
            include_examples 'apt repositories', 'php', { :location => 'https://apt.publiq.be/php-focal-testing', :repos => 'main', :release => 'focal' }

            # Do we need to check for the architecture for these repositories?
            include_examples 'apt repositories', 'docker', { :location => 'https://apt.publiq.be/docker-testing', :repos => 'stable', :release => 'focal' }
            include_examples 'apt repositories', 'newrelic', { :location => 'https://apt.publiq.be/newrelic-testing', :repos => 'non-free', :release => 'focal' }
            include_examples 'apt repositories', 'newrelic-infra', { :location => 'https://apt.publiq.be/newrelic-infra-focal-testing', :repos => 'main', :release => 'focal' }

            include_examples 'apt repositories', 'publiq-tools', { :location => 'https://apt.publiq.be/publiq-tools-focal-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'nodejs-16', { :location => 'https://apt.publiq.be/nodejs-16-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'nodejs-18', { :location => 'https://apt.publiq.be/nodejs-18-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'nodejs-20', { :location => 'https://apt.publiq.be/nodejs-20-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'elastic-5.x', { :location => 'https://apt.publiq.be/elastic-5.x-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'elastic-8.x', { :location => 'https://apt.publiq.be/elastic-8.x-testing', :repos => 'main', :release => 'focal' }

            include_examples 'apt repositories', 'publiq-jenkins', { :location => 'https://apt.publiq.be/publiq-jenkins-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'publiq-prototypes', { :location => 'https://apt.publiq.be/publiq-prototypes-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'publiq-versions', { :location => 'https://apt.publiq.be/publiq-versions-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'publiq-infrastructure', { :location => 'https://apt.publiq.be/publiq-infrastructure-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'publiq-infrastructure-legacy', { :location => 'https://apt.publiq.be/publiq-infrastructure-legacy-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'publiq-appconfig', { :location => 'https://apt.publiq.be/publiq-appconfig-testing', :repos => 'main', :release => 'focal' }

            include_examples 'apt repositories', 'museumpas-mspotm', { :location => 'https://apt.publiq.be/museumpas-mspotm-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'museumpas-website', { :location => 'https://apt.publiq.be/museumpas-website-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'museumpas-website-filament', { :location => 'https://apt.publiq.be/museumpas-website-filament-testing', :repos => 'main', :release => 'focal' }

            include_examples 'apt repositories', 'uitdatabank-angular-app', { :location => 'https://apt.publiq.be/uitdatabank-angular-app-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitdatabank-newsletter-api', { :location => 'https://apt.publiq.be/uitdatabank-newsletter-api-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitdatabank-search-api', { :location => 'https://apt.publiq.be/uitdatabank-search-api-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitdatabank-geojson-data', { :location => 'https://apt.publiq.be/uitdatabank-geojson-data-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitdatabank-frontend', { :location => 'https://apt.publiq.be/uitdatabank-frontend-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitdatabank-jwt-provider', { :location => 'https://apt.publiq.be/uitdatabank-jwt-provider-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitdatabank-jwt-provider-uitidv1', { :location => 'https://apt.publiq.be/uitdatabank-jwt-provider-uitidv1-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitdatabank-movie-api-fetcher', { :location => 'https://apt.publiq.be/uitdatabank-movie-api-fetcher-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitdatabank-entry-api', { :location => 'https://apt.publiq.be/uitdatabank-entry-api-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitdatabank-websocket-server', { :location => 'https://apt.publiq.be/uitdatabank-websocket-server-testing', :repos => 'main', :release => 'focal' }

            include_examples 'apt repositories', 'curator-articlelinker', { :location => 'https://apt.publiq.be/curator-articlelinker-testing', :repos => 'main', :release => 'focal' }

            include_examples 'apt repositories', 'widgetbeheer-frontend', { :location => 'https://apt.publiq.be/widgetbeheer-frontend-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'projectaanvraag-api', { :location => 'https://apt.publiq.be/projectaanvraag-api-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'projectaanvraag-frontend', { :location => 'https://apt.publiq.be/projectaanvraag-frontend-testing', :repos => 'main', :release => 'focal' }

            include_examples 'apt repositories', 'uitid-app', { :location => 'https://apt.publiq.be/uitid-app-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitid-frontend', { :location => 'https://apt.publiq.be/uitid-frontend-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitid-api', { :location => 'https://apt.publiq.be/uitid-api-testing', :repos => 'main', :release => 'focal' }

            include_examples 'apt repositories', 'uitpas-app', { :location => 'https://apt.publiq.be/uitpas-app-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitpas-website-api', { :location => 'https://apt.publiq.be/uitpas-website-api-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitpas-website-frontend', { :location => 'https://apt.publiq.be/uitpas-website-frontend-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitpas-groepspas-frontend', { :location => 'https://apt.publiq.be/uitpas-groepspas-frontend-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitpas-balie-frontend', { :location => 'https://apt.publiq.be/uitpas-balie-frontend-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitpas-balie-api', { :location => 'https://apt.publiq.be/uitpas-balie-api-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uitpas-balie', { :location => 'https://apt.publiq.be/uitpas-balie-testing', :repos => 'main', :release => 'focal' }

            include_examples 'apt repositories', 'uit-mail-subscriptions', { :location => 'https://apt.publiq.be/uit-mail-subscriptions-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uit-notifications', { :location => 'https://apt.publiq.be/uit-notifications-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uit-recommender-frontend', { :location => 'https://apt.publiq.be/uit-recommender-frontend-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uit-frontend', { :location => 'https://apt.publiq.be/uit-frontend-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uit-api', { :location => 'https://apt.publiq.be/uit-api-testing', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'uit-cms', { :location => 'https://apt.publiq.be/uit-cms-testing', :repos => 'main', :release => 'focal' }
          end

          context 'in the acceptance environment' do
            let(:environment) { 'acceptance' }

            # How do we test a different environment?
            it { is_expected.to contain_apt__source('focal').with(
              'location' => 'https://apt.publiq.be/focal-acceptance'
            ) }

            include_examples 'apt repositories', 'focal', { :location => 'https://apt.publiq.be/focal-acceptance', :repos => 'main', :release => 'focal' }
            include_examples 'apt repositories', 'php', { :location => 'https://apt.publiq.be/php-focal-acceptance', :repos => 'main', :release => 'focal' }
          end
        end
      end
    end
  end
end
