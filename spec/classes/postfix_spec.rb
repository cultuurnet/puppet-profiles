require 'spec_helper'

describe 'profiles::postfix' do
  include_examples 'operating system support', 'profiles::postfix'

  context "on Ubuntu 14.04" do
    let(:facts) { {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :operatingsystemrelease => '14.04'
      }
    }

    it { is_expected.to compile.with_all_deps }

    context "without parameters" do
      let(:params) { { } }

      it { is_expected.to contain_class('postfix::server').with(
        'inet_protocols'          => 'all',
        'inet_interfaces'         => 'all',
        'smtp_use_tls'            => 'yes',
        'relayhost'               => false,
        'smtp_tls_security_level' => 'may',
        'extra_main_parameters'   => { 'smtp_tls_loglevel'   => '1' }
        )
      }

      it { is_expected.not_to contain_postfix__dbfile('virtual') }
    end

    context "with relayhost => [mailhost.example.com]" do
      let(:params) { { 'relayhost' => '[mailhost.example.com]' } }

      it { is_expected.to contain_class('postfix::server').with(
        'inet_protocols'          => 'all',
        'inet_interfaces'         => 'all',
        'smtp_use_tls'            => 'yes',
        'relayhost'               => '[mailhost.example.com]',
        'smtp_tls_security_level' => 'may',
        'extra_main_parameters'   => { 'smtp_tls_loglevel'   => '1' }
        )
      }

      it { is_expected.not_to contain_postfix__dbfile('virtual') }
    end

    context "without tls" do
      let(:params) { { 'tls' => false } }

      it { is_expected.to contain_class('postfix::server').with(
        'inet_protocols'  => 'all',
        'inet_interfaces' => 'all',
        'smtp_use_tls'    => 'no',
        'relayhost'       => false
        )
      }

      it { is_expected.not_to contain_postfix__dbfile('virtual') }

      context "with inet_protocols => ipv4, listen_addresses => 127.0.0.1 and relayhost => [mailhost.example.com]" do
        let(:params) {
          super().merge(
            {
              'inet_protocols'   => 'ipv4',
              'listen_addresses' => '127.0.0.1',
              'relayhost'        => '[mailhost.example.com]'
            }
          )
        }

        it { is_expected.to contain_class('postfix::server').with(
          'inet_protocols'  => 'ipv4',
          'inet_interfaces' => '127.0.0.1',
          'smtp_use_tls'    => 'no',
          'relayhost'       => '[mailhost.example.com]'
          )
        }

        it { is_expected.not_to contain_postfix__dbfile('virtual') }
      end

      context "with aliases" do
        let(:params) {
          super().merge(
            {
              'aliases' => true
            }
          )
        }

        it { is_expected.to contain_class('postfix::server').with(
          'inet_protocols'        => 'all',
          'inet_interfaces'       => 'all',
          'smtp_use_tls'          => 'no',
          'relayhost'             => false,
          'virtual_alias_maps'    => [ 'hash:/etc/postfix/virtual'],
          'virtual_alias_domains' => []
          )
        }

        it { is_expected.to contain_postfix__dbfile('virtual').with(
          'source' => 'puppet:///modules/profiles/postfix/virtual'
        )
        }

        context "with aliases_domains => [ foo.com, bar.com ]" do
          let(:params) {
            super().merge(
              {
                'aliases_domains' => [ 'foo.com', 'bar.com' ]
              }
            )
          }

          it { is_expected.to contain_class('postfix::server').with(
            'inet_protocols'        => 'all',
            'inet_interfaces'       => 'all',
            'smtp_use_tls'          => 'no',
            'relayhost'             => false,
            'virtual_alias_maps'    => [ 'hash:/etc/postfix/virtual'],
            'virtual_alias_domains' => [ 'foo.com', 'bar.com' ]
            )
          }

          it { is_expected.to contain_postfix__dbfile('virtual').with(
            'source' => 'puppet:///modules/profiles/postfix/virtual'
          )
          }
        end

        context "with aliases_source => puppet:///private/postfix/virtual" do
          let(:params) {
            super().merge(
              {
                'aliases_source' => 'puppet:///private/postfix/virtual'
              }
            )
          }

          it { is_expected.to contain_postfix__dbfile('virtual').with(
            'source' => 'puppet:///private/postfix/virtual'
          )
          }
        end
      end
    end
  end
end
