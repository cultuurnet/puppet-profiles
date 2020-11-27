require 'spec_helper'

describe 'profiles::mailcatcher' do
  include_examples 'operating system support', 'profiles::mailcatcher'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_profiles__apt__update('cultuurnet-tools') }

      it { is_expected.to contain_class('mailcatcher').with(
        'manage_repo' => false
        )
      }

      it { is_expected.to contain_class('mailcatcher').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }
    end
  end
end
