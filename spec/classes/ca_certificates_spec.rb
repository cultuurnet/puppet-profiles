require 'spec_helper'

describe 'profiles::ca_certificates' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::ca_certificates').with(
          'disabled_ca_certificates' => [],
          'publiq_development_ca'    => false
        ) }

        it { is_expected.not_to contain_apt__source('publiq-tools') }
        it { is_expected.not_to contain_package('ca-certificates-publiq') }

        it { is_expected.to have_augeas_resource_count(0) }
      end

      context "with disabled_ca_certificates => 'foobar'" do
        let(:params) { {
            'disabled_ca_certificates' => 'foobar'
        } }

        it { is_expected.not_to contain_apt__source('publiq-tools') }
        it { is_expected.not_to contain_package('ca-certificates-publiq') }

        it { is_expected.to contain_augeas('Disable CA certificate foobar').with(
          'lens'    => 'Simplelines.lns',
          'incl'    => '/etc/ca-certificates.conf',
          'context' => '/files/etc/ca-certificates.conf',
          'onlyif'  => 'get *[.= \'foobar\'] == \'foobar\'',
          'changes' => 'set *[.= \'foobar\'] \'!foobar\'',
        ) }

        it { is_expected.to contain_exec('Update CA certificates').with(
          'command'     => 'update-ca-certificates',
          'path'        => [ '/usr/local/bin', '/usr/bin', '/usr/sbin', '/bin'],
          'refreshonly' => true
        ) }

        it { is_expected.to contain_augeas('Disable CA certificate foobar').that_notifies('Exec[Update CA certificates]') }
      end

      context "with disabled_ca_certificates => ['badcert', 'expiredcert'] and publiq_development_root_ca => true" do
        let(:params) { {
          'disabled_ca_certificates' => ['badcert', 'expiredcert'],
          'publiq_development_ca'    => true
        } }

        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_package('ca-certificates-publiq') }

        it { is_expected.to contain_augeas('Disable CA certificate badcert').with(
          'lens'    => 'Simplelines.lns',
          'incl'    => '/etc/ca-certificates.conf',
          'context' => '/files/etc/ca-certificates.conf',
          'onlyif'  => 'get *[.= \'badcert\'] == \'badcert\'',
          'changes' => 'set *[.= \'badcert\'] \'!badcert\'',
        ) }

        it { is_expected.to contain_augeas('Disable CA certificate expiredcert').with(
          'lens'    => 'Simplelines.lns',
          'incl'    => '/etc/ca-certificates.conf',
          'context' => '/files/etc/ca-certificates.conf',
          'onlyif'  => 'get *[.= \'expiredcert\'] == \'expiredcert\'',
          'changes' => 'set *[.= \'expiredcert\'] \'!expiredcert\'',
        ) }

        it { is_expected.to contain_exec('Update CA certificates').with(
          'command'     => 'update-ca-certificates',
          'path'        => ['/usr/local/bin', '/usr/bin', '/usr/sbin', '/bin'],
          'refreshonly' => true
        ) }

        it { is_expected.to contain_package('ca-certificates-publiq').that_notifies('Exec[Update CA certificates]') }
        it { is_expected.to contain_augeas('Disable CA certificate badcert').that_notifies('Exec[Update CA certificates]') }
        it { is_expected.to contain_augeas('Disable CA certificate expiredcert').that_notifies('Exec[Update CA certificates]') }
      end
    end
  end
end
