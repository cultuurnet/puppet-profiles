class profiles::packages {

  @package { 'composer':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'git':
    ensure => 'present'
  }
}
