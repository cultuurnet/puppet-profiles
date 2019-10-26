require 'spec_helper'

describe 'profiles::firewall' do
  let(:pre_condition) { 'include ::profiles' }

  include_examples 'operating system support', 'profiles::firewall'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Firewall <| |>' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_firewall('100 accept ssh traffic').with(
          'proto'  => 'tcp',
          'dport'  => '22',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('300 accept smtp traffic').with(
          'proto' => 'tcp',
          'dport' => '25',
          'action' => 'accept'
        ) }
      end
    end
  end
end
