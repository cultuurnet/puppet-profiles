require 'spec_helper'

describe 'profiles::puppet::agent' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_service('puppet').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
          )
        }

        it { is_expected.to contain_ini_setting('agent certificate_revocation').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'certificate_revocation',
          'value'   => false,
          )
        }

        it { is_expected.to contain_ini_setting('agent usecacheonfailure').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'usecacheonfailure',
          'value'   => false,
          )
        }

        it { is_expected.to contain_ini_setting('agent preferred_serialization_format').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'preferred_serialization_format',
          'value'   => 'pson',
          )
        }

        it { is_expected.to contain_ini_setting('agent certificate_revocation').that_notifies('Service[puppet]') }
        it { is_expected.to contain_ini_setting('agent usecacheonfailure').that_notifies('Service[puppet]') }
        it { is_expected.to contain_ini_setting('agent preferred_serialization_format').that_notifies('Service[puppet]') }
      end

      context "with ensure => stopped and enable => false" do
        let(:params) { {
          'ensure' => 'stopped',
          'enable' => false
        } }

        it { is_expected.to contain_service('puppet').with(
          'ensure' => 'stopped',
          'enable' => false
          )
        }
      end
    end
  end
end
