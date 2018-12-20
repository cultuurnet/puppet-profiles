class profiles::packages {

  include ::profiles

  @package { 'composer':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'git':
    ensure => 'present'
  }
}
