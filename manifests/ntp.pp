class profiles::ntp (
  Array[String] $servers = [],
) {

  contain ::profiles

  $restrict = [
    '-4 default kod nomodify notrap nopeer noquery',
    '-6 default kod nomodify notrap nopeer noquery',
    '127.0.0.1',
    '::1'
  ]

  if $facts['ec2_metadata'] {
    class { '::ntp':
      servers  => [ '169.254.169.123'],
      restrict => $restrict
    }
  } else {
    if $servers == [] {
      class { '::ntp':
        restrict => $restrict
      }
    } else {
      class { '::ntp':
        servers  => $servers,
        restrict => $restrict
      }
    }
  }
}
