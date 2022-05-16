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
          'server' => 'keyserver.ubuntu.com',
          'source' => 'https://apt.publiq.be/gpgkey/cultuurnet.gpg.key'
        ) }

        it { is_expected.to contain_apt__key('publiq Infrastructure').with(
          'id'     => 'AD726BD2A48017B060AA43FA4A49242DE36CDCAF',
          'server' => 'keyserver.ubuntu.com',
          'source' => 'https://apt.publiq.be/gpgkey/publiq.gpg.key'
        ) }

        it { is_expected.to contain_apt__key('aptly').with(
          'id'     => '26DA9D8630302E0B86A7A2CBED75B5A4483DA07C',
          'server' => 'keyserver.ubuntu.com',
          'source' => 'https://www.aptly.info/pubkey.txt'
        ) }

        it { is_expected.to contain_apt__key('Ubuntu archive').with(
          'id'     => '790BC7277767219C42C86F933B4FE6ACC0B21F32',
          'server' => 'keyserver.ubuntu.com'
        ) }
      end
    end
  end
end
