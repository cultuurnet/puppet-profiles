class profiles::puppet::puppetserver::install (
  String $version = 'installed'
) inherits ::profiles {

  include profiles::java

  realize Group['puppet']
  realize User['puppet']
  realize Apt::Source['puppet']

  package { 'puppetserver':
    ensure  => $version,
    require => [Class['profiles::java'], Group['puppet'], User['puppet']]
  }
}
