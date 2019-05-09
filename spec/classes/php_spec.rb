require 'spec_helper'

describe 'profiles::php' do
  let(:pre_condition) { 'include profiles::base' }

  include_examples 'operating system support', 'profiles::php'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_package('composer').with(
        'ensure' => 'present'
        )
      }

      it { is_expected.to contain_package('git').with(
        'ensure' => 'present'
        )
      }
    end
  end
end
