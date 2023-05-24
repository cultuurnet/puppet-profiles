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
          'trusted_amis' => []
        ) }

        it { is_expected.to contain_group('puppet') }
        it { is_expected.to contain_user('puppet') }

        it { is_expected.to contain_file('puppetserver autosign').with(
          'ensure' => 'file',
          'path'   => '/etc/puppetlabs/puppet/autosign',
          'owner'  => 'puppet',
          'group'  => 'puppet',
          'mode'   => '0750'
        ) }

        it { is_expected.to contain_file('puppetserver autosign').with_content(/^TRUSTED_AMIS = \[\]$/) }

        it { is_expected.to contain_package('aws-sdk-ec2').with(
          'ensure'   => 'installed',
          'provider' => 'puppetserver_gem'
        ) }

        it { is_expected.to contain_group('puppet').that_comes_before('File[puppetserver autosign]') }
        it { is_expected.to contain_user('puppet').that_comes_before('File[puppetserver autosign]') }
      end

      context "with trusted_amis => ami-123" do
        let(:params) { {
          'trusted_amis' => 'ami-123'
        } }

        it { is_expected.to contain_file('puppetserver autosign').with_content(/^TRUSTED_AMIS = \['ami-123'\]$/) }
      end

      context "with trusted_amis => [ami-234, ami-567]" do
        let(:params) { {
          'trusted_amis' => ['ami-234', 'ami-567']
        } }

        it { is_expected.to contain_file('puppetserver autosign').with_content(/^TRUSTED_AMIS = \['ami-234', 'ami-567'\]$/) }
      end
    end
  end
end
