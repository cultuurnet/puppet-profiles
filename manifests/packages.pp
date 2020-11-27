class profiles::packages {

  include ::profiles::apt::updates

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

  @package { 'elasticdump':
    ensure  => 'present',
    require => [ Profiles::Apt::Update['cultuurnet-tools'], Profiles::Apt::Update['nodejs_10.x']]
  }

  @package { 'gcsfuse':
    ensure  => 'present',
    require => Profiles::Apt::Update['cultuurnet-tools']
  }

  @package { 'liquibase':
    ensure  => 'present',
    require => Profiles::Apt::Update['cultuurnet-tools']
  }

  @package { 'mysql-connector-java':
    ensure  => 'present',
    require => Profiles::Apt::Update['cultuurnet-tools']
  }

  @package { 'yarn':
    ensure  => 'present',
    require => Profiles::Apt::Update['cultuurnet-tools']
  }
}
