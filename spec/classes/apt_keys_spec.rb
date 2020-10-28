require 'spec_helper'

describe 'profiles::apt_keys' do
  include_examples 'operating system support', 'profiles::apt_keys'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_apt__key('Infra CultuurNet').with(
        'id'     => '2380EA3E50D3776DFC1B03359F4935C80DC9EA95',
        'server' => 'keyserver.ubuntu.com',
        'source' => 'http://apt.uitdatabank.be/gpgkey/cultuurnet.gpg.key'
      )
      }

      it { is_expected.to contain_apt__key('publiq Infrastructure').with(
        'id'     => 'AD726BD2A48017B060AA43FA4A49242DE36CDCAF',
        'server' => 'keyserver.ubuntu.com',
        'source' => 'https://apt.publiq.be/gpgkey/publiq.gpg.key'
      )
      }
    end
  end
end
