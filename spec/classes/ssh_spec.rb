require 'spec_helper'

describe 'profiles::ssh' do
  include_examples 'operating system support', 'profiles::ssh'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_sshd_config('PermitRootLogin').with(
        'ensure' => 'present',
        'value'  => 'no'
        )
      }

      it { is_expected.to contain_sshd_config('PermitRootLogin').that_notifies('Service[ssh]') }

      it { is_expected.to contain_service('ssh').with(
        'ensure' => 'running',
        'enable' => true
        )
      }

      it { is_expected.to contain_firewall('100 accept ssh traffic').with(
        'proto'  => 'tcp',
        'dport'  => '22',
        'action' => 'accept'
      ) }
    end
  end
end
