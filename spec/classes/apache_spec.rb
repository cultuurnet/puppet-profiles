require 'spec_helper'

describe 'profiles::apache' do
  include_examples 'operating system support', 'profiles::apache'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('apache') }
    end
  end
end
