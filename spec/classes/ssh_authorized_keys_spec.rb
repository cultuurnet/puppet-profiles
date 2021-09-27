require 'spec_helper'

describe 'profiles::ssh_authorized_keys' do
  let(:pre_condition) { 'include ::profiles' }

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

        context "with keys => { foo => { type => ssh-rsa, key => abcd1234, tag => publiq } }, bar => { type => ssh-rsa, key => [ efgh5678, ijkl9012 ], tag => publiq } }, baz => { type => ssh-rsa, key => efgh5678, tag => acme } }" do
          let(:params) {
            {
              'keys' => {
                'foo' => { 'type' => 'ssh-rsa', 'key' => 'abcd1234', 'tag' => 'publiq' },
                'bar' => { 'type' => 'ssh-rsa', 'key' => [ 'efgh5678', 'ijkl9012'] , 'tag' => 'publiq' },
                'baz' => { 'type' => 'ssh-rsa', 'key' => 'efgh5678', 'tag' => 'acme' }
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
            'type' => 'ssh-rsa',
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
