require 'spec_helper'

describe 'profiles::firewall' do
  include_examples 'operating system support', 'profiles::firewall'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('firewall') }

      it { is_expected.to contain_resources('firewall').with(
        'purge' => true
      ) }
    end
  end
end
