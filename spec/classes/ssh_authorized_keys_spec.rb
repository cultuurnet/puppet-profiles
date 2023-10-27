require 'spec_helper'

describe 'profiles::ssh_authorized_keys' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Ssh_authorized_key <| |>' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to have_ssh_authorized_key_resource_count(0) }
        end

        context "with keys => { foo => { tag => publiq, keys => { type => ssh-rsa, key => abcd1234 } }, bar => { tag => publiq, keys => [{ type => ssh-rsa, key => efgh5678 }, { type => ed25519, key => ijkl9012 }] }, baz => { tag => acme, keys => {type => ssh-rsa, key => efgh5678} } }" do
          let(:params) {
            {
              'keys' => {
                'foo' => { 'tag' => 'publiq', 'keys' => { 'type' => 'ssh-rsa', 'key' => 'abcd1234' } },
                'bar' => { 'tag' => 'publiq', 'keys' => [{ 'type' => 'ssh-rsa', 'key' => 'efgh5678' }, { 'type' => 'ed25519', 'key' => 'ijkl9012' }] },
                'baz' => { 'tag' => 'acme', 'keys' => { 'type' => 'ssh-rsa', 'key' => 'efgh5678' } }
              }
            }
          }

          it { is_expected.to contain_ssh_authorized_key('foo').with(
            'user' => 'ubuntu',
            'type' => 'ssh-rsa',
            'key'  => 'abcd1234',
            'tag'  => 'publiq'
          ) }

          it { is_expected.to contain_ssh_authorized_key('bar 1').with(
            'user' => 'ubuntu',
            'type' => 'ssh-rsa',
            'key'  => 'efgh5678',
            'tag'  => 'publiq'
          ) }

          it { is_expected.to contain_ssh_authorized_key('bar 2').with(
            'user' => 'ubuntu',
            'type' => 'ed25519',
            'key'  => 'ijkl9012',
            'tag'  => 'publiq'
          ) }

          it { is_expected.to contain_ssh_authorized_key('baz').with(
            'user' => 'ubuntu',
            'type' => 'ssh-rsa',
            'key'  => 'efgh5678',
            'tag'  => 'acme'
          ) }
        end
      end
    end
  end
end
