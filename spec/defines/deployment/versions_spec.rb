require 'spec_helper'

describe 'profiles::deployment::versions' do
  let(:title) { 'exampleproject' }

  context "with project => example" do
    let(:params) { {
      'project'  => 'example'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        context "with packages => foo" do
          let(:pre_condition) { 'package { "foo":}' }

          let(:params) {
            super().merge( {
              'packages'        => 'foo'
            } )
          }

          it { is_expected.not_to contain_exec('update facts for package foo') }
        end

        context "with packages => [ 'bar', 'baz'] and puppetdb_url => http://localhost:8080" do
          let(:pre_condition) { 'package { "bar":}; package { "baz":}' }

          let(:params) {
            super().merge( {
              'packages'     => [ 'bar', 'baz'],
              'puppetdb_url' => 'http://localhost:8080'
            } )
          }

          it { is_expected.to contain_exec('update facts for package bar').with(
            'command'     => 'update_facts -p http://localhost:8080',
            'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
            'refreshonly' => true
            )
          }

          it { is_expected.to contain_exec('update facts for package baz').with(
            'command'     => 'update_facts -p http://localhost:8080',
            'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
            'refreshonly' => true
            )
          }

          it { is_expected.to contain_exec('update facts for package bar').that_subscribes_to('Package[bar]') }
          it { is_expected.to contain_exec('update facts for package baz').that_subscribes_to('Package[baz]') }

          it { is_expected.to contain_exec('update facts for package bar').that_subscribes_to('Class[profiles::deployment]') }
          it { is_expected.to contain_exec('update facts for package baz').that_subscribes_to('Class[profiles::deployment]') }
        end
      end
    end
  end

  context "without parameters" do
    let(:params) { {} }

    it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'project'/) }
  end
end
