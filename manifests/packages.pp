class profiles::packages {

  include ::profiles::repositories

  @package { 'composer':
    ensure  => 'present',
    require => Profiles::Apt::Update['cultuurnet-tools']
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
    require => Profiles::Apt::Update['cultuurnet-tools']
  }

  @package { 'jq':
    ensure => 'present'
  }
}
