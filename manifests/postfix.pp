class profiles::postfix (
  Boolean                     $tls              = true,
  Enum['ipv4', 'ipv6', 'all'] $inet_protocols   = 'all',
  String                      $listen_addresses = 'all',
  Boolean                     $aliases          = false,
  Array[String]               $aliases_domains  = [],
  String                      $aliases_source   = 'puppet:///modules/profiles/postfix/virtual'
) {

  include ::profiles

  if $aliases {
    if $tls {
      class { '::postfix::server':
        inet_protocols          => $inet_protocols,
        inet_interfaces         => $listen_addresses,
        virtual_alias_maps      => [ 'hash:/etc/postfix/virtual'],
        virtual_alias_domains   => $aliases_domains,
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
        virtual_alias_maps    => [ 'hash:/etc/postfix/virtual'],
        virtual_alias_domains => $aliases_domains,
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
        smtp_use_tls            => 'yes',
        smtp_tls_security_level => 'may',
        extra_main_parameters   => {
          'smtp_tls_loglevel'   => '1'
        }
      }
    } else {
      class { '::postfix::server':
        inet_protocols  => $inet_protocols,
        inet_interfaces => $listen_addresses,
        smtp_use_tls    => 'no'
      }
    }
  }
}
