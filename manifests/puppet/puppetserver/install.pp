class profiles::puppet::puppetserver::install (
  String $version = 'installed'
) inherits ::profiles {

  include profiles::java

  realize Group['puppet']
  realize User['puppet']
  realize Apt::Source['openvox']
  realize Apt::Source['puppet']

  package { 'openvox-server':
    ensure  => $version,
    require => [Class['profiles::java'], Group['puppet'], User['puppet']]
  }

  package { 'puppetserver':
    ensure  => 'purged'
  }
}
