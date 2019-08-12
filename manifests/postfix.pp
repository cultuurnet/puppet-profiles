class profiles::postfix (
  Boolean                     $tls              = true,
  Enum['ipv4', 'ipv6', 'all'] $inet_protocols   = 'all',
  String                      $listen_addresses = 'all',
  String                      $relayhost        = '',
  Boolean                     $aliases          = false,
  Array[String]               $aliases_domains  = [],
  String                      $aliases_source   = 'puppet:///modules/profiles/postfix/virtual'
) {

  contain ::profiles

  $config_directory = '/etc/postfix'
  $mynetworks_file = "${config_directory}/mynetworks"

  if $relayhost == '' {
    $relay_host  = false
    $my_networks = "${config_directory}/mynetworks"

    Concat::Fragment <<| tag == 'postfix_mynetworks' |>>

    concat { $mynetworks_file:
      notify => Class['::postfix::server']
    }
  } else {
    $relay_host  = $relayhost
    $my_networks = false
  }

  @@concat::fragment { "postfix_mynetworks_${facts['ec2_metadata']['public-ipv4']}":
    target  => $mynetworks_file,
    content => "${facts['ec2_metadata']['public-ipv4']}\n",
    tag     => 'postfix_mynetworks'
  }

  if $aliases {
    if $tls {
      class { '::postfix::server':
        inet_protocols          => $inet_protocols,
        inet_interfaces         => $listen_addresses,
        virtual_alias_maps      => [ "hash:${config_directory}/virtual"],
        virtual_alias_domains   => $aliases_domains,
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
        inet_protocols        => $inet_protocols,
        inet_interfaces       => $listen_addresses,
        virtual_alias_maps    => [ "hash:${config_directory}/virtual"],
        virtual_alias_domains => $aliases_domains,
        relayhost             => $relay_host,
        mynetworks            => $my_networks,
        message_size_limit    => '0',
        mailbox_size_limit    => '0',
        smtp_use_tls          => 'no'
      }
    }

    postfix::dbfile { 'virtual':
      source  => $aliases_source,
      require => Class['::postfix::server']
    }
  } else {
    if $tls {
      class { '::postfix::server':
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
