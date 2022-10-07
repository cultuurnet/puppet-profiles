require 'spec_helper'

describe 'profiles::puppet::agent' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with puppetserver => puppet.example.com" do
        let(:params) { {
          'puppetserver' => 'puppet.example.com'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_service('puppet').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
          )
        }

        it { is_expected.to contain_ini_setting('puppetserver').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'server',
          'value'   => 'puppet.example.com'
          )
        }

        it { is_expected.to contain_ini_setting('agent certificate_revocation').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'certificate_revocation',
          'value'   => false
          )
        }

        it { is_expected.to contain_ini_setting('agent usecacheonfailure').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'usecacheonfailure',
          'value'   => false
          )
        }

        it { is_expected.to contain_ini_setting('agent preferred_serialization_format').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'preferred_serialization_format',
          'value'   => 'pson'
          )
        }

        it { is_expected.to contain_ini_setting('agent certificate_revocation').that_notifies('Service[puppet]') }
        it { is_expected.to contain_ini_setting('agent usecacheonfailure').that_notifies('Service[puppet]') }
        it { is_expected.to contain_ini_setting('agent preferred_serialization_format').that_notifies('Service[puppet]') }
      end

      context "with puppetserver => foo.bar.com, ensure => stopped and enable => false" do
        let(:params) { {
          'puppetserver' => 'foo.bar.com',
          'ensure'       => 'stopped',
          'enable'       => false
        } }

        it { is_expected.to contain_ini_setting('puppetserver').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'server',
          'value'   => 'foo.bar.com'
          )
        }

        it { is_expected.to contain_service('puppet').with(
          'ensure' => 'stopped',
          'enable' => false
          )
        }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'puppetserver'/) }
      end
    end
  end
end
