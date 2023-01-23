require 'spec_helper'

describe 'profiles::aptly::gpgkeys' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { [
          'Profiles::Aptly::Gpgkey <| |>'
        ] }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__aptly__gpgkey('aptly').with(
          'key_id'     => '78D6517AB92E22947F577996A0546A43624A8331',
          'key_source' => 'https://www.aptly.info/pubkey.txt'
        ) }

        it { is_expected.to contain_profiles__aptly__gpgkey('Ubuntu archive').with(
          'key_id'     => '790BC7277767219C42C86F933B4FE6ACC0B21F32',
          'key_server' => 'hkp://keyserver.ubuntu.com'
        ) }

        it { is_expected.to contain_profiles__aptly__gpgkey('newrelic').with(
          'key_id'     => 'B60A3EC9BC013B9C23790EC8B31B29E5548C16BF',
          'key_source' => 'https://download.newrelic.com/548C16BF.gpg'
        ) }

        it { is_expected.to contain_profiles__aptly__gpgkey('newrelic-infra').with(
          'key_id'     => 'A758B3FBCD43BE8D123A3476BB29EE038ECCE87C',
          'key_source' => 'https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg'
        ) }

        it { is_expected.to contain_profiles__aptly__gpgkey('elasticsearch').with(
          'key_id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
          'key_source' => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
        ) }

        it { is_expected.to contain_profiles__aptly__gpgkey('nodejs').with(
          'key_id'     => '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280',
          'key_source' => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'
        ) }
      end
    end
  end
end
