require 'spec_helper'

describe 'profiles' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to contain_class('profiles::stages') }
    end
  end
end
