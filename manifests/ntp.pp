class profiles::ntp (
  Optional[Array[String]] $servers = undef,
) {

  contain ::profiles

  $restrict = [
    '-4 default kod nomodify notrap nopeer noquery',
    '-6 default kod nomodify notrap nopeer noquery',
    '127.0.0.1',
    '::1'
  ]

  if $facts['ec2_metadata'] {
    $ntp_servers = [ '169.254.169.123']
  } else {
    $ntp_servers = $servers
  }

  class { '::ntp':
    servers  => $ntp_servers,
    restrict => $restrict
  }
}
