require 'spec_helper'

describe 'profiles::apt::keys' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { [
          'include ::apt',
          'Apt::Key <| |>'
        ] }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__key('Infra CultuurNet').with(
          'id'     => '2380EA3E50D3776DFC1B03359F4935C80DC9EA95',
          'source' => 'https://apt.publiq.be/gpgkey/cultuurnet.gpg.key'
        ) }

        it { is_expected.to contain_apt__key('publiq Infrastructure').with(
          'id'     => 'AD726BD2A48017B060AA43FA4A49242DE36CDCAF',
          'source' => 'https://apt.publiq.be/gpgkey/publiq.gpg.key'
        ) }

        it { is_expected.to contain_apt__key('aptly').with(
          'id'     => '78D6517AB92E22947F577996A0546A43624A8331',
          'source' => 'https://www.aptly.info/pubkey.txt'
        ) }

        it { is_expected.to contain_apt__key('Ubuntu archive').with(
          'id'     => '790BC7277767219C42C86F933B4FE6ACC0B21F32',
          'server' => 'keyserver.ubuntu.com'
        ) }

        it { is_expected.to contain_apt__key('newrelic').with(
          'id'     => 'B60A3EC9BC013B9C23790EC8B31B29E5548C16BF',
          'source' => 'https://download.newrelic.com/548C16BF.gpg'
        ) }

        it { is_expected.to contain_apt__key('newrelic-infra').with(
          'id'     => 'A758B3FBCD43BE8D123A3476BB29EE038ECCE87C',
          'source' => 'https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg'
        ) }

        it { is_expected.to contain_apt__key('elasticsearch').with(
          'id'     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
          'source' => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
        ) }

        it { is_expected.to contain_apt__key('nodejs').with(
          'id'     => '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280',
          'source' => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'
        ) }
      end
    end
  end
end
