require 'spec_helper'

describe 'profiles::firewall::base' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('firewall') }

      it { is_expected.to contain_resources('firewall').with(
        'purge' => true
      ) }

      it { is_expected.to contain_firewall('000 accept all ICMP traffic').with(
        'proto'  => 'icmp',
        'action' => 'accept'
      ) }

      it { is_expected.to contain_firewall('001 accept all traffic to lo interface').with(
        'proto'   => 'all',
        'iniface' => 'lo',
        'action'  => 'accept'
      ) }

      it { is_expected.to contain_firewall('002 reject local traffic not on loopback interface').with(
        'proto'       => 'all',
        'iniface'     => '! lo',
        'destination' => '127.0.0.0/8',
        'action'      => 'reject'
      ) }

      it { is_expected.to contain_firewall('003 accept related established rules').with(
        'proto'  => 'all',
        'state'  => ['RELATED', 'ESTABLISHED'],
        'action' => 'accept'
      ) }

      it { is_expected.to contain_firewall('999 drop all').with(
        'proto'  => 'all',
        'action' => 'drop',
        'before' => nil
      ) }
    end
  end
end
