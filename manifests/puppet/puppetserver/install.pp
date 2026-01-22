class profiles::puppet::puppetserver::install (
  String $version = 'installed'
) inherits ::profiles {

  include profiles::java

  realize Group['puppet']
  realize User['puppet']
  realize Apt::Source['openvox']

  package { 'openvox-server':
    ensure  => $version,
    require => [Class['profiles::java'], Apt::Source['openvox'], Group['puppet'], User['puppet']]
  }
}
