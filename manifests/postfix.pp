class profiles::postfix (
  Boolean                        $tls               = true,
  Enum['ipv4', 'ipv6', 'all']    $inet_protocols    = 'ipv4',
  String                         $listen_addresses  = 'all',
  Optional[String]               $relayhost         = undef,
  Boolean                        $aliases           = false,
  Variant[String, Array[String]] $aliases_domains   = [],
  Variant[String, Array[String]] $extra_allowed_ips = [],
  String                         $aliases_source    = 'puppet:///modules/profiles/postfix/virtual'
) inherits ::profiles {

  include ::profiles::firewall::rules

  $config_directory = '/etc/postfix'
  $mynetworks_file  = "${config_directory}/mynetworks"

  if !($relayhost) {
    $relay_host  = false
    $my_networks = "${config_directory}/mynetworks"

    @@concat::fragment { "postfix_mynetworks_127.0.0.1":
      target  => $mynetworks_file,
      content => "127.0.0.1\n",
      tag     => 'postfix_mynetworks'
    }

    [$extra_allowed_ips].flatten.each |$ip| {
      @@concat::fragment { "postfix_mynetworks_${ip}":
        target  => $mynetworks_file,
        content => "${ip}\n",
        tag     => 'postfix_mynetworks'
      }
    }

    if $settings::storeconfigs {
      Concat::Fragment <<| tag == 'postfix_mynetworks' |>>
    }

    file { $config_directory:
      ensure => 'directory'
    }

    concat { $mynetworks_file:
      require => File[$config_directory],
      notify  => Class['::postfix::server']
    }

    realize Firewall['300 accept SMTP traffic']

  } else {
    $relay_host  = $relayhost ? {
                     /^\[.*\]$/ => $relayhost,
                     default    => "[${relayhost}]"
                   }
    $my_networks = false
  }

  @@concat::fragment { "postfix_mynetworks_${facts['networking']['ip']}":
    target  => $mynetworks_file,
    content => "${facts['networking']['ip']}\n",
    tag     => 'postfix_mynetworks'
  }

  if $aliases {
    if $tls {
      class { '::postfix::server':
        daemon_directory        => '/usr/lib/postfix/sbin',
        inet_protocols          => $inet_protocols,
        inet_interfaces         => $listen_addresses,
        virtual_alias_maps      => [ "hash:${config_directory}/virtual"],
        virtual_alias_domains   => [$aliases_domains].flatten,
        relayhost               => $relay_host,
        mynetworks              => $my_networks,
        message_size_limit      => '0',
        mailbox_size_limit      => '0',
        smtp_use_tls            => 'yes',
        smtp_tls_security_level => 'may',
        extra_main_parameters   => {
          'smtp_tls_loglevel'            => '1',
          'smtpd_recipient_restrictions' => 'permit_mynetworks,reject_unauth_destination',
          'smtpd_relay_restrictions'     => 'permit_mynetworks,reject_unauth_destination'
        }
      }
    } else {
      class { '::postfix::server':
        daemon_directory      => '/usr/lib/postfix/sbin',
        inet_protocols        => $inet_protocols,
        inet_interfaces       => $listen_addresses,
        virtual_alias_maps    => [ "hash:${config_directory}/virtual"],
        virtual_alias_domains => [$aliases_domains].flatten,
        relayhost             => $relay_host,
        mynetworks            => $my_networks,
        message_size_limit    => '0',
        mailbox_size_limit    => '0',
        smtp_use_tls          => 'no',
        extra_main_parameters   => {
          'smtpd_recipient_restrictions' => 'permit_mynetworks,reject_unauth_destination',
          'smtpd_relay_restrictions'     => 'permit_mynetworks,reject_unauth_destination'
        }
      }
    }

    postfix::dbfile { 'virtual':
      source  => $aliases_source,
      require => Class['::postfix::server']
    }
  } else {
    if $tls {
      class { '::postfix::server':
        daemon_directory        => '/usr/lib/postfix/sbin',
        inet_protocols          => $inet_protocols,
        inet_interfaces         => $listen_addresses,
        relayhost               => $relay_host,
        mynetworks              => $my_networks,
        message_size_limit      => '0',
        mailbox_size_limit      => '0',
        smtp_use_tls            => 'yes',
        smtp_tls_security_level => 'may',
        extra_main_parameters   => {
          'smtp_tls_loglevel'   => '1'
        }
      }
    } else {
      class { '::postfix::server':
        daemon_directory   => '/usr/lib/postfix/sbin',
        inet_protocols     => $inet_protocols,
        inet_interfaces    => $listen_addresses,
        relayhost          => $relay_host,
        mynetworks         => $my_networks,
        message_size_limit => '0',
        mailbox_size_limit => '0',
        smtp_use_tls       => 'no'
      }
    }
  }
}
