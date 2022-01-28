require 'spec_helper'

describe 'profiles' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to contain_class('profiles::stages') }
      it { is_expected.to contain_class('profiles::apt') }

      it { is_expected.to contain_class('profiles::apt::repositories').with(
        'stage' => 'pre'
      ) }

      it { is_expected.to contain_class('profiles::deployment::repositories').with(
        'stage' => 'pre'
      ) }

      it { is_expected.to contain_class('deployment::repositories').with(
        'stage' => 'pre'
      ) }
    end
  end
end
