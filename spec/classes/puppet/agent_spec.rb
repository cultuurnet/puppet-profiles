require 'spec_helper'

describe 'profiles::puppet::agent' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::puppet::agent').with(
          'version'        => 'installed',
          'puppetserver'   => nil,
          'service_ensure' => 'stopped',
          'service_enable' => false
        ) }

        it { is_expected.to contain_apt__source('puppet') }

        it { is_expected.to contain_package('puppet-agent').with(
          'ensure'    => 'installed'
        ) }

        it { is_expected.to contain_service('puppet').with(
          'ensure'    => 'stopped',
          'enable'    => false,
          'hasstatus' => true
        ) }

        it { is_expected.not_to contain_ini_setting('puppetserver') }

        it { is_expected.to contain_ini_setting('agent certificate_revocation').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'certificate_revocation',
          'value'   => false
        ) }

        it { is_expected.to contain_ini_setting('agent usecacheonfailure').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'usecacheonfailure',
          'value'   => false
        ) }

        it { is_expected.to contain_ini_subsetting('agent reports').with(
          'ensure'               => 'present',
          'path'                 => '/etc/puppetlabs/puppet/puppet.conf',
          'section'              => 'main',
          'setting'              => 'reports',
          'subsetting'           => 'store',
          'subsetting_separator' => ','
        ) }

        it { is_expected.to contain_apt__source('puppet').that_comes_before('Package[puppet-agent]') }
        it { is_expected.to contain_package('puppet-agent').that_notifies('Service[puppet]') }
        it { is_expected.to contain_ini_setting('agent certificate_revocation').that_notifies('Service[puppet]') }
        it { is_expected.to contain_ini_setting('agent usecacheonfailure').that_notifies('Service[puppet]') }
        it { is_expected.to contain_ini_subsetting('agent reports').that_notifies('Service[puppet]') }
      end

      context "with version => 6.23.1, puppetserver => puppet.example.com, service_ensure => running and service_enable => true" do
        let(:params) { {
          'version'        => '6.23.1',
          'puppetserver'   => 'puppet.example.com',
          'service_ensure' => 'running',
          'service_enable' => true
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('puppet-agent').with(
          'ensure'    => '6.23.1'
        ) }

        it { is_expected.to contain_service('puppet').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_ini_setting('puppetserver').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'main',
          'setting' => 'server',
          'value'   => 'puppet.example.com'
        ) }

        it { is_expected.to contain_ini_setting('puppetserver').that_notifies('Service[puppet]') }
      end

      context "on AWS EC2" do
        let(:facts) do
          super().merge({ 'ec2_metadata' => 'true'})
        end

        context "with EC2 tag 'Environment => acceptance'" do
          let(:facts) do
            super().merge({ 'ec2_tags' => {'environment' => 'acceptance'} })
          end

          it { is_expected.to contain_ini_setting('environment').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'main',
            'setting' => 'environment',
            'value'   => 'acceptance'
          ) }

          it { is_expected.to contain_ini_setting('environment').that_notifies('Service[puppet]') }
        end

        context "with EC2 tag 'Environment => production'" do
          let(:facts) do
            super().merge({ 'ec2_tags' => {'environment' => 'production'} })
          end

          it { is_expected.to contain_ini_setting('environment').with(
            'value' => 'production'
          ) }
        end
      end

      context "not on AWS EC2" do
        let(:facts) do
          super()
        end

        it { is_expected.not_to contain_ini_setting('environment') }
      end
    end
  end
end
