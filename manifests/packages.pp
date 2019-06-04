class profiles::packages {

  @package { 'composer':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'git':
    ensure => 'present'
  }

  @package { 'amqp-tools':
    ensure => 'present'
  }

  @package { 'awscli':
    ensure => 'present'
  }

  @package { 'ca-certificates-publiq':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }
}
