require 'spec_helper'

describe 'profiles::postfix' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on host with ipaddress 1.2.3.4" do
        let(:facts) {
          super().merge(
            { 'networking' => { 'ip' => '1.2.3.4' } }
          )
        }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::postfix').with(
           'tls'               => true,
           'inet_protocols'    => 'ipv4',
           'listen_addresses'  => 'all',
           'relayhost'         => nil,
           'aliases'           => false,
           'aliases_domains'   => [],
           'extra_allowed_ips' => [],
           'aliases_source'    => 'puppet:///modules/profiles/postfix/virtual'
          ) }

          it { is_expected.to contain_class('postfix::server').with(
            'daemon_directory'        => '/usr/lib/postfix/sbin',
            'inet_protocols'          => 'ipv4',
            'inet_interfaces'         => 'all',
            'smtp_use_tls'            => 'yes',
            'relayhost'               => false,
            'mynetworks'              => '/etc/postfix/mynetworks',
            'message_size_limit'      => '0',
            'mailbox_size_limit'      => '0',
            'smtp_tls_security_level' => 'may',
            'extra_main_parameters'   => { 'smtp_tls_loglevel' => '1' }
          ) }

          it { is_expected.not_to contain_postfix__dbfile('virtual') }

          it { expect(exported_resources).to contain_concat__fragment('postfix_mynetworks_127.0.0.1').with(
            'target'  => '/etc/postfix/mynetworks',
            'content' => "127.0.0.1\n",
            'tag'     => 'postfix_mynetworks'
          ) }

          it { expect(exported_resources).to contain_concat__fragment('postfix_mynetworks_1.2.3.4').with(
            'target'  => '/etc/postfix/mynetworks',
            'content' => "1.2.3.4\n",
            'tag'     => 'postfix_mynetworks'
          ) }

          it { is_expected.to contain_file('/etc/postfix').with(
            'ensure' => 'directory'
          ) }

          it { is_expected.to contain_concat('/etc/postfix/mynetworks') }

          it { is_expected.to contain_firewall('300 accept SMTP traffic').with(
            'proto' => 'tcp',
            'dport' => '25',
            'action' => 'accept'
          ) }

          it { is_expected.to contain_concat('/etc/postfix/mynetworks').that_requires('File[/etc/postfix]') }
          it { is_expected.to contain_concat('/etc/postfix/mynetworks').that_notifies('Class[postfix::server]') }
        end

        context "with tls => false and listen_addresses => 127.0.0.1" do
          let(:params) { {
            'tls'              => false,
            'listen_addresses' => '127.0.0.1'
          } }

          it { is_expected.to contain_class('postfix::server').with(
            'daemon_directory'   => '/usr/lib/postfix/sbin',
            'inet_protocols'     => 'ipv4',
            'inet_interfaces'    => '127.0.0.1',
            'smtp_use_tls'       => 'no',
            'relayhost'          => false,
            'mynetworks'         => '/etc/postfix/mynetworks',
            'message_size_limit' => '0',
            'mailbox_size_limit' => '0'
          ) }

          it { is_expected.not_to contain_postfix__dbfile('virtual') }

          it { expect(exported_resources).to contain_concat__fragment('postfix_mynetworks_1.2.3.4').with(
            'target'  => '/etc/postfix/mynetworks',
            'content' => "1.2.3.4\n",
            'tag'     => 'postfix_mynetworks'
          ) }

          it { is_expected.to contain_file('/etc/postfix').with(
            'ensure' => 'directory'
          ) }

          it { is_expected.to contain_concat('/etc/postfix/mynetworks') }

          it { is_expected.to contain_firewall('300 accept SMTP traffic').with(
            'proto' => 'tcp',
            'dport' => '25',
            'action' => 'accept'
          ) }

          it { is_expected.to contain_concat('/etc/postfix/mynetworks').that_requires('File[/etc/postfix]') }
          it { is_expected.to contain_concat('/etc/postfix/mynetworks').that_notifies('Class[postfix::server]') }
        end

        context "with relayhost => [mailhost.example.com]" do
          let(:params) { { 'relayhost' => '[mailhost.example.com]' } }

          it { is_expected.to contain_class('postfix::server').with(
            'daemon_directory'        => '/usr/lib/postfix/sbin',
            'inet_protocols'          => 'ipv4',
            'inet_interfaces'         => 'all',
            'smtp_use_tls'            => 'yes',
            'relayhost'               => '[mailhost.example.com]',
            'mynetworks'              => false,
            'message_size_limit'      => '0',
            'mailbox_size_limit'      => '0',
            'smtp_tls_security_level' => 'may',
            'extra_main_parameters'   => { 'smtp_tls_loglevel' => '1' }
          ) }

          it { is_expected.not_to contain_postfix__dbfile('virtual') }

          it { expect(exported_resources).not_to contain_concat__fragment('postfix_mynetworks_127.0.0.1') }

          it { expect(exported_resources).to contain_concat__fragment('postfix_mynetworks_1.2.3.4').with(
            'target'  => '/etc/postfix/mynetworks',
            'content' => "1.2.3.4\n",
            'tag'     => 'postfix_mynetworks'
          ) }

          it { is_expected.not_to contain_firewall('300 accept SMTP traffic') }

          it { is_expected.not_to contain_file('/etc/postfix') }
          it { is_expected.not_to contain_concat('/etc/postfix/mynetworks') }
        end

        context "with relayhost => mailhost.example.com" do
          let(:params) { { 'relayhost' => 'mailhost.example.com' } }

          it { is_expected.to contain_class('postfix::server').with(
            'daemon_directory'        => '/usr/lib/postfix/sbin',
            'inet_protocols'          => 'ipv4',
            'inet_interfaces'         => 'all',
            'smtp_use_tls'            => 'yes',
            'relayhost'               => '[mailhost.example.com]',
            'mynetworks'              => false,
            'message_size_limit'      => '0',
            'mailbox_size_limit'      => '0',
            'smtp_tls_security_level' => 'may',
            'extra_main_parameters'   => { 'smtp_tls_loglevel' => '1' }
          ) }
        end
      end

      context "on host with ipaddress 5.6.7.8" do
        let(:facts) {
          super().merge(
            { 'networking' => { 'ip' => '5.6.7.8' } }
          )
        }

        context "with inet_protocols => all and relayhost => [mailhost.example.com]" do
          let(:params) { {
            'inet_protocols'   => 'all',
            'relayhost'        => '[mailhost.example.com]'
          } }

          it { is_expected.to contain_class('postfix::server').with(
            'daemon_directory'   => '/usr/lib/postfix/sbin',
            'inet_protocols'     => 'all',
            'inet_interfaces'    => 'all',
            'smtp_use_tls'       => 'yes',
            'relayhost'          => '[mailhost.example.com]',
            'mynetworks'         => false,
            'message_size_limit' => '0',
            'mailbox_size_limit' => '0'
          ) }

          it { is_expected.not_to contain_postfix__dbfile('virtual') }

          it { expect(exported_resources).to contain_concat__fragment('postfix_mynetworks_5.6.7.8').with(
            'target'  => '/etc/postfix/mynetworks',
            'content' => "5.6.7.8\n",
            'tag'     => 'postfix_mynetworks'
          ) }

          it { is_expected.not_to contain_firewall('300 accept SMTP traffic') }

          it { is_expected.not_to contain_file('/etc/postfix') }
          it { is_expected.not_to contain_concat('/etc/postfix/mynetworks') }
        end

        context "with aliases and extra_allowed_ips => ['8.7.6.5', '9.10.11.12']" do
          let(:params) { {
            'aliases'           => true,
            'extra_allowed_ips' => ['8.7.6.5', '9.10.11.12']
          } }

          it { is_expected.to contain_class('postfix::server').with(
            'daemon_directory'      => '/usr/lib/postfix/sbin',
            'inet_protocols'        => 'ipv4',
            'inet_interfaces'       => 'all',
            'smtp_use_tls'          => 'yes',
            'relayhost'             => false,
            'mynetworks'            => '/etc/postfix/mynetworks',
            'message_size_limit'    => '0',
            'mailbox_size_limit'    => '0',
            'virtual_alias_maps'    => [ 'hash:/etc/postfix/virtual'],
            'virtual_alias_domains' => [],
            'extra_main_parameters'   => {
              'smtp_tls_loglevel' => '1',
              'smtpd_recipient_restrictions' => 'permit_mynetworks,reject_unauth_destination',
              'smtpd_relay_restrictions'     => 'permit_mynetworks,reject_unauth_destination'
            }
          ) }

          it { is_expected.to contain_postfix__dbfile('virtual').with(
            'source' => 'puppet:///modules/profiles/postfix/virtual'
          ) }

          it { expect(exported_resources).to contain_concat__fragment('postfix_mynetworks_5.6.7.8').with(
            'target'  => '/etc/postfix/mynetworks',
            'content' => "5.6.7.8\n",
            'tag'     => 'postfix_mynetworks'
          ) }

          it { expect(exported_resources).to contain_concat__fragment('postfix_mynetworks_8.7.6.5').with(
            'target'  => '/etc/postfix/mynetworks',
            'content' => "8.7.6.5\n",
            'tag'     => 'postfix_mynetworks'
          ) }

          it { expect(exported_resources).to contain_concat__fragment('postfix_mynetworks_9.10.11.12').with(
            'target'  => '/etc/postfix/mynetworks',
            'content' => "9.10.11.12\n",
            'tag'     => 'postfix_mynetworks'
          ) }

          it { is_expected.to contain_file('/etc/postfix').with(
            'ensure' => 'directory'
          ) }

          it { is_expected.to contain_concat('/etc/postfix/mynetworks') }

          it { is_expected.to contain_firewall('300 accept SMTP traffic').with(
            'proto' => 'tcp',
            'dport' => '25',
            'action' => 'accept'
          ) }

          it { is_expected.to contain_concat('/etc/postfix/mynetworks').that_requires('File[/etc/postfix]') }
          it { is_expected.to contain_concat('/etc/postfix/mynetworks').that_notifies('Class[postfix::server]') }

          context "with aliases_domains => [foo.com, bar.com]" do
            let(:params) {
              super().merge({
                'aliases_domains' => ['foo.com', 'bar.com']
              } )
            }

            it { is_expected.to contain_class('postfix::server').with(
              'daemon_directory'      => '/usr/lib/postfix/sbin',
              'inet_protocols'        => 'ipv4',
              'inet_interfaces'       => 'all',
              'smtp_use_tls'          => 'yes',
              'relayhost'             => false,
              'mynetworks'            => '/etc/postfix/mynetworks',
              'message_size_limit'    => '0',
              'mailbox_size_limit'    => '0',
              'virtual_alias_maps'    => ['hash:/etc/postfix/virtual'],
              'virtual_alias_domains' => ['foo.com', 'bar.com']
            ) }

            it { is_expected.to contain_postfix__dbfile('virtual').with(
              'source' => 'puppet:///modules/profiles/postfix/virtual'
            ) }

            it { expect(exported_resources).to contain_concat__fragment('postfix_mynetworks_5.6.7.8').with(
              'target'  => '/etc/postfix/mynetworks',
              'content' => "5.6.7.8\n",
              'tag'     => 'postfix_mynetworks'
            ) }

            it { is_expected.to contain_firewall('300 accept SMTP traffic').with(
              'proto' => 'tcp',
              'dport' => '25',
              'action' => 'accept'
            ) }
          end

          context "with aliases_source => puppet:///private/postfix/virtual" do
            let(:params) {
              super().merge({
                'aliases_source' => 'puppet:///private/postfix/virtual'
              } )
            }

            it { is_expected.to contain_postfix__dbfile('virtual').with(
              'source' => 'puppet:///private/postfix/virtual'
            ) }
          end
        end

        context "with aliases => true, aliases_domains => baz.com and extra_allowed_ips => '1.2.3.4'" do
          let(:params) { {
              'aliases'           => true,
              'aliases_domains'   => 'baz.com',
              'extra_allowed_ips' => '1.2.3.4'
          } }

          it { is_expected.to contain_class('postfix::server').with(
            'daemon_directory'      => '/usr/lib/postfix/sbin',
            'inet_protocols'        => 'ipv4',
            'inet_interfaces'       => 'all',
            'smtp_use_tls'          => 'yes',
            'relayhost'             => false,
            'mynetworks'            => '/etc/postfix/mynetworks',
            'message_size_limit'    => '0',
            'mailbox_size_limit'    => '0',
            'virtual_alias_maps'    => ['hash:/etc/postfix/virtual'],
            'virtual_alias_domains' => ['baz.com'],
            'extra_main_parameters'   => {
              'smtp_tls_loglevel' => '1',
              'smtpd_recipient_restrictions' => 'permit_mynetworks,reject_unauth_destination',
              'smtpd_relay_restrictions'     => 'permit_mynetworks,reject_unauth_destination'
            }
          ) }

          it { expect(exported_resources).to contain_concat__fragment('postfix_mynetworks_1.2.3.4').with(
            'target'  => '/etc/postfix/mynetworks',
            'content' => "1.2.3.4\n",
            'tag'     => 'postfix_mynetworks'
          ) }
        end
      end
    end
  end
end
