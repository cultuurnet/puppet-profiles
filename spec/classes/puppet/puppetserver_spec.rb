require 'spec_helper'

describe 'profiles::puppet::puppetserver' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on host aaa.example.com" do
        let(:node) { 'aaa.example.com' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::puppet::puppetserver').with(
            'version'           => 'installed',
            'dns_alt_names'     => nil,
            'autosign'          => false,
            'trusted_amis'      => [],
            'initial_heap_size' => nil,
            'maximum_heap_size' => nil,
            'service_status'    => 'running'
          ) }

          it { is_expected.to contain_group('puppet') }
          it { is_expected.to contain_user('puppet') }

          it { is_expected.to contain_apt__source('puppet') }
          it { is_expected.to contain_firewall('300 accept puppetserver HTTPS traffic') }

          it { is_expected.to contain_class('profiles::java') }
          it { is_expected.to contain_package('puppetserver').with(
            'ensure' => 'installed'
          ) }

          it { is_expected.to contain_ini_setting('puppetserver ca_server').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'ca_server',
            'value'   => 'aaa.example.com'
          ) }

          it { is_expected.to contain_ini_setting('puppetserver dns_alt_names').with(
            'ensure'  => 'absent',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'dns_alt_names'
          ) }

          it { is_expected.to contain_ini_setting('puppetserver autosign').with(
            'ensure'  => 'absent',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'autosign'
          ) }

          it { is_expected.to contain_service('puppetserver').with(
            'ensure'    => 'running',
            'enable'    => true,
            'hasstatus' => true
          ) }

          it { is_expected.not_to contain_augeas('puppetserver_initial_heap_size') }
          it { is_expected.not_to contain_augeas('puppetserver_maximum_heap_size') }

          it { is_expected.not_to contain_class('profiles::puppet::puppetserver::autosign') }

          it { is_expected.to contain_package('puppetserver').that_requires('Group[puppet]') }
          it { is_expected.to contain_package('puppetserver').that_requires('User[puppet]') }
          it { is_expected.to contain_package('puppetserver').that_requires('Ini_setting[puppetserver ca_server]') }
          it { is_expected.to contain_package('puppetserver').that_requires('Ini_setting[puppetserver dns_alt_names]') }
          it { is_expected.to contain_package('puppetserver').that_requires('Apt::Source[puppet]') }
          it { is_expected.to contain_package('puppetserver').that_requires('Class[profiles::java]') }
          it { is_expected.to contain_package('puppetserver').that_notifies('Service[puppetserver]') }
          it { is_expected.to contain_ini_setting('puppetserver ca_server').that_notifies('Service[puppetserver]') }
        end

        context "with version => 1.2.3, dns_alt_names => puppet.services.example.com, autosign => true, trusted_amis => ami-123, initial_heap_size => 512m, maximum_heap_size => 512m and service_status => stopped" do
          let(:params) { {
            'version'           => '1.2.3',
            'dns_alt_names'     => 'puppet.services.example.com',
            'autosign'          => true,
            'trusted_amis'      => 'ami-123',
            'initial_heap_size' => '512m',
            'maximum_heap_size' => '512m',
            'service_status'    => 'stopped'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_package('puppetserver').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_augeas('puppetserver_initial_heap_size').with(
            'lens'    => 'Shellvars_list.lns',
            'incl'    => '/etc/default/puppetserver',
            'context' => '/files/etc/default/puppetserver/JAVA_ARGS',
            'changes' => "set value[. =~ regexp('-Xms.*')] '-Xms512m'"
          ) }

          it { is_expected.to contain_augeas('puppetserver_maximum_heap_size').with(
            'lens'    => 'Shellvars_list.lns',
            'incl'    => '/etc/default/puppetserver',
            'context' => '/files/etc/default/puppetserver/JAVA_ARGS',
            'changes' => "set value[. =~ regexp('-Xmx.*')] '-Xmx512m'"
          ) }

          it { is_expected.to contain_ini_setting('puppetserver dns_alt_names').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'dns_alt_names',
            'value'   => 'puppet.services.example.com'
          ) }

          it { is_expected.to contain_ini_setting('puppetserver autosign').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'autosign',
            'value'   => '/etc/puppetlabs/puppet/autosign'
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::autosign').with(
           'trusted_amis' => 'ami-123'
          ) }

          it { is_expected.to contain_service('puppetserver').with(
            'ensure'    => 'stopped',
            'enable'    => false,
            'hasstatus' => true
          ) }

          it { is_expected.to contain_ini_setting('puppetserver autosign').that_notifies('Service[puppetserver]') }
          it { is_expected.to contain_class('profiles::puppet::puppetserver::autosign').that_notifies('Service[puppetserver]') }
          it { is_expected.to contain_augeas('puppetserver_initial_heap_size').that_notifies('Service[puppetserver]') }
          it { is_expected.to contain_augeas('puppetserver_maximum_heap_size').that_notifies('Service[puppetserver]') }
        end
      end

      context "on host bbb.example.com" do
        let(:node) { 'bbb.example.com' }

        context "with autosign => true, trusted_amis => [ami-234, ami-567] and dns_alt_names => [puppet1.services.example.com, puppet2.services.example.com]" do
          let(:params) { {
            'autosign'      => true,
            'trusted_amis'  => ['ami-234', 'ami-567'],
            'dns_alt_names' => ['puppet1.services.example.com', 'puppet2.services.example.com'],
          } }

          it { is_expected.to contain_ini_setting('puppetserver ca_server').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'ca_server',
            'value'   => 'bbb.example.com'
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::autosign').with(
           'trusted_amis' => ['ami-234', 'ami-567']
          ) }

          it { is_expected.to contain_ini_setting('puppetserver dns_alt_names').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'dns_alt_names',
            'value'   => 'puppet1.services.example.com,puppet2.services.example.com'
          ) }
        end
      end
    end
  end
end
