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

        it { is_expected.to contain_apt__key('publiq Infrastructure').with(
          'id'     => 'AD726BD2A48017B060AA43FA4A49242DE36CDCAF',
          'source' => 'https://apt.publiq.be/gpgkey/publiq.gpg.key'
        ) }

        it { is_expected.to contain_apt__key('aptly').with(
          'id'     => '78D6517AB92E22947F577996A0546A43624A8331',
          'source' => 'https://www.aptly.info/pubkey.txt'
        ) }
      end
    end
  end
end
