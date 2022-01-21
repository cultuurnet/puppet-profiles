require 'spec_helper'

describe 'profiles::certificates' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Profiles::Certificate <| |>' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::certificates').with(
            'certificates' => {},
            'disabled_ca_certificates' => []
          ) }

          it { is_expected.to have_profiles__certificate_resource_count(0) }

          it { is_expected.to have_augeas_resource_count(0) }
        end

        context "with certificates => { 'foo.example.com' => { 'certificate_source' => '/tmp/cert/foo', 'key_source' => '/tmp/cert/foo.key' }, 'bar.example.com' => { 'certificate_source' => '/tmp/cert/bar', 'key_source' => '/tmp/cert/bar.key' }} and disabled_ca_certificates => 'foobar'" do
          let(:params) {
            {
              'certificates'             => {
                'foo.example.com' => { 'certificate_source' => '/tmp/cert/foo', 'key_source' => '/tmp/cert/foo.key' },
                'bar.example.com' => { 'certificate_source' => '/tmp/cert/bar', 'key_source' => '/tmp/cert/bar.key' }
              },
              'disabled_ca_certificates' => 'foobar'
            }
          }

          it { is_expected.to contain_profiles__certificate('foo.example.com').with(
            'certificate_source' => '/tmp/cert/foo',
            'key_source'         => '/tmp/cert/foo.key'
          ) }

          it { is_expected.to contain_profiles__certificate('bar.example.com').with(
            'certificate_source' => '/tmp/cert/bar',
            'key_source'         => '/tmp/cert/bar.key'
          ) }

          it { is_expected.to contain_augeas('Disable CA certificate foobar').with(
            'lens'    => 'Simplelines.lns',
            'incl'    => '/etc/ca-certificates.conf',
            'context' => '/files/etc/ca-certificates.conf',
            'onlyif'  => 'get *[.= \'foobar\'] == \'foobar\'',
            'changes' => 'set *[.= \'foobar\'] \'!foobar\'',
          ) }

          it { is_expected.to contain_augeas('Disable CA certificate foobar').that_notifies('Class[profiles::certificates::update]') }
        end

        context "with certificates => { 'baz.example.com' => { 'certificate_source' => '/tmp/cert/baz', 'key_source' => '/tmp/cert/baz.key' }} and disabled_ca_certificates => [ 'badcert', 'expiredcert']" do
          let(:params) {
            {
              'certificates'             => {
                'baz.example.com' => { 'certificate_source' => '/tmp/cert/baz', 'key_source' => '/tmp/cert/baz.key' }
              },
              'disabled_ca_certificates' => ['badcert', 'expiredcert']
            }
          }

          it { is_expected.to contain_profiles__certificate('baz.example.com').with(
            'certificate_source' => '/tmp/cert/baz',
            'key_source'         => '/tmp/cert/baz.key'
          ) }

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

          it { is_expected.to contain_augeas('Disable CA certificate badcert').that_notifies('Class[profiles::certificates::update]') }
          it { is_expected.to contain_augeas('Disable CA certificate expiredcert').that_notifies('Class[profiles::certificates::update]') }
        end
      end
    end
  end
end
