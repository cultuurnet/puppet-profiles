require 'spec_helper'

describe 'profiles::ssh' do
  let(:hiera_config) { 'spec/support/hiera/hiera.yaml' }

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_sshd_config('PermitRootLogin').with(
          'ensure' => 'present',
          'value'  => 'no'
        ) }

        it { is_expected.to contain_sshd_config('PermitRootLogin').that_notifies('Service[ssh]') }

        it { is_expected.to contain_service('ssh').with(
          'ensure' => 'running',
          'enable' => true
        ) }

        it { is_expected.to contain_file('ssh_known_hosts').with(
          'ensure' => 'file',
          'path'   => '/etc/ssh/ssh_known_hosts',
          'mode'   => '0644'
        ) }

        it { is_expected.to contain_resources('sshkey').with(
          'purge' => true
        ) }

        it { is_expected.to contain_resources('ssh_authorized_key').with(
          'purge' => true
        ) }

        it { is_expected.to contain_firewall('100 accept SSH traffic').with(
          'proto'  => 'tcp',
          'dport'  => '22',
          'action' => 'accept'
        ) }

        it { is_expected.to have_ssh_authorized_key_resource_count(0) }
      end

      context "with ssh_authorized_keys_tags => publiq" do
        let(:params) { { 'ssh_authorized_keys_tags' => 'publiq' } }

        it { is_expected.to contain_ssh_authorized_key('publiq first key') }
        it { is_expected.to contain_ssh_authorized_key('publiq second key') }
      end

      context "with ssh_authorized_keys_tags => [ publiq, acme]" do
        let(:params) { { 'ssh_authorized_keys_tags' => [ 'publiq', 'acme'] } }

        it { is_expected.to contain_ssh_authorized_key('publiq first key') }
        it { is_expected.to contain_ssh_authorized_key('publiq second key') }
        it { is_expected.to contain_ssh_authorized_key('acme first key') }

        it { is_expected.to have_ssh_authorized_key_resource_count(3) }
      end
    end
  end
end
