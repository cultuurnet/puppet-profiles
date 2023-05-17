require 'spec_helper'

describe 'profiles::puppet::puppetserver' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::puppet::puppetserver').with(
          'version'           => 'latest',
          'initial_heap_size' => nil,
          'maximum_heap_size' => nil,
          'service_manage'    => true,
          'service_enable'    => true,
          'service_ensure'    => 'running'
        ) }

        it { is_expected.to contain_group('puppet') }
        it { is_expected.to contain_user('puppet') }

        it { is_expected.to contain_apt__source('puppet') }
        it { is_expected.to contain_firewall('300 accept puppetserver HTTPS traffic') }

        it { is_expected.to contain_class('profiles::java') }
        it { is_expected.to contain_package('puppetserver').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_service('puppetserver').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.not_to contain_augeas('puppetserver_initial_heap_size') }
        it { is_expected.not_to contain_augeas('puppetserver_maximum_heap_size') }

        it { is_expected.to contain_package('puppetserver').that_requires('Group[puppet]') }
        it { is_expected.to contain_package('puppetserver').that_requires('User[puppet]') }
        it { is_expected.to contain_package('puppetserver').that_requires('Apt::Source[puppet]') }
        it { is_expected.to contain_package('puppetserver').that_requires('Class[profiles::java]') }
        it { is_expected.to contain_package('puppetserver').that_notifies('Service[puppetserver]') }
      end

      context "with version => 1.2.3, service_enable => false and service_ensure => stopped" do
        let(:params) { {
          'version'           => '1.2.3',
          'initial_heap_size' => '512m',
          'maximum_heap_size' => '512m',
          'service_enable'    => false,
          'service_ensure'    => 'stopped'
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

        it { is_expected.to contain_service('puppetserver').with(
          'ensure'    => 'stopped',
          'enable'    => false,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_augeas('puppetserver_initial_heap_size').that_notifies('Service[puppetserver]') }
        it { is_expected.to contain_augeas('puppetserver_maximum_heap_size').that_notifies('Service[puppetserver]') }
      end

      context "with service_manage => false" do
        let(:params) { {
          'service_manage' => false
        } }

        it { is_expected.not_to contain_service('puppetserver') }
      end
    end
  end
end
