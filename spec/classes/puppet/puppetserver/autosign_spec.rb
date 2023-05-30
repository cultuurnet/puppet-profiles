require 'spec_helper'

describe 'profiles::puppet::puppetserver::autosign' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::puppet::puppetserver::autosign').with(
          'autosign'          => false,
          'trusted_amis'      => [],
          'trusted_certnames' => []
        ) }

        it { is_expected.to contain_ini_setting('puppetserver autosign').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'server',
          'setting' => 'autosign',
          'value'   => false
        ) }

        it { is_expected.to contain_file('puppetserver autosign').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/puppet/autosign'
        ) }

        it { is_expected.to contain_file('puppetserver autosign.conf').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/puppet/autosign.conf'
        ) }
      end

      context "with autosign => true and trusted_certnames => aaa.example.com" do
        let(:params) { {
          'autosign'          => true,
          'trusted_certnames' => 'aaa.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('puppet') }
        it { is_expected.to contain_user('puppet') }

        it { is_expected.to contain_ini_setting('puppetserver autosign').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'server',
          'setting' => 'autosign',
          'value'   => true
        ) }

        it { is_expected.to contain_file('puppetserver autosign').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/puppet/autosign'
        ) }

        it { is_expected.to contain_file('puppetserver autosign.conf').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppetlabs/puppet/autosign.conf',
          'owner'   => 'puppet',
          'group'   => 'puppet',
          'mode'    => '0640',
          'content' => 'aaa.example.com'
        ) }

        it { is_expected.to contain_group('puppet').that_comes_before('File[puppetserver autosign.conf]') }
        it { is_expected.to contain_user('puppet').that_comes_before('File[puppetserver autosign.conf]') }
      end

      context "with autosign => true and trusted_amis => ami-123" do
        let(:params) { {
          'autosign'     => true,
          'trusted_amis' => 'ami-123'
        } }

        it { is_expected.to contain_group('puppet') }
        it { is_expected.to contain_user('puppet') }

        it { is_expected.to contain_ini_setting('puppetserver autosign').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'server',
          'setting' => 'autosign',
          'value'   => '/etc/puppetlabs/puppet/autosign'
        ) }

        it { is_expected.to contain_file('puppetserver autosign').with(
          'ensure' => 'file',
          'path'   => '/etc/puppetlabs/puppet/autosign',
          'owner'  => 'puppet',
          'group'  => 'puppet',
          'mode'   => '0750'
        ) }

        it { is_expected.to contain_file('puppetserver autosign.conf').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/puppet/autosign.conf'
        ) }

        it { is_expected.to contain_file('puppetserver autosign').with_content(/^TRUSTED_AMIS = \['ami-123'\]$/) }

        it { is_expected.to contain_package('aws-sdk-ec2').with(
          'ensure'   => 'installed',
          'provider' => 'puppetserver_gem'
        ) }

        it { is_expected.to contain_group('puppet').that_comes_before('File[puppetserver autosign]') }
        it { is_expected.to contain_user('puppet').that_comes_before('File[puppetserver autosign]') }
      end

      context "with autosign => true and trusted_certnames => [a.example.com, b.example.com, *.c.example.com]" do
        let(:params) { {
          'autosign'          => true,
          'trusted_certnames' => ['a.example.com', 'b.example.com', '*.c.example.com']
        } }

        it { is_expected.to contain_file('puppetserver autosign.conf').with_content("a.example.com\nb.example.com\n*.c.example.com") }
      end

      context "with autosign => true and trusted_amis => [ami-234, ami-567]" do
        let(:params) { {
          'autosign'     => true,
          'trusted_amis' => ['ami-234', 'ami-567']
        } }

        it { is_expected.to contain_file('puppetserver autosign').with_content(/^TRUSTED_AMIS = \['ami-234', 'ami-567'\]$/) }
      end

      context "with autosign => true, trusted_certnames => [a.example.com, b.example.com, *.c.example.com] and trusted_amis => ['ami-234', 'ami-567']" do
        let(:params) { {
          'autosign'          => true,
          'trusted_amis'      => ['ami-234', 'ami-567'],
          'trusted_certnames' => ['a.example.com', 'b.example.com', '*.c.example.com'],
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects either a value for parameter 'trusted_amis' or 'trusted_certnames' when autosigning/) }
      end
    end
  end
end
