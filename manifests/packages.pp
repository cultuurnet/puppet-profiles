class profiles::packages inherits ::profiles {

  @package { 'composer':
    ensure  => 'absent'
  }

  @package { 'composer1':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'composer2':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'drush':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'git':
    ensure => 'present'
  }

  @package { 'groovy':
    ensure => 'present'
  }

  @package { 'amqp-tools':
    ensure => 'present'
  }

  @package { 'awscli':
    ensure => 'present'
  }

  @package { 'graphviz':
    ensure => 'present'
  }

  @package { 'fontconfig':
    ensure => 'present'
  }

  @package { 'ca-certificates-publiq':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'jq':
    ensure => 'present'
  }

  @package { 'gcsfuse':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'liquibase':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'mysql-connector-java':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'yarn':
    ensure  => 'present',
    require => Apt::Source['yarn']
  }

  @package { 'bundler':
    ensure => 'present'
  }

  @package { 'policykit-1':
    ensure  => 'latest',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'snapd':
    ensure  => 'latest',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'qemu-user-static':
    ensure  => 'present'
  }

  @package { 'libssl1.1':
    ensure  => 'present',
    require => Apt::Source['cultuurnet-tools']
  }

  @package { 'build-essential':
    ensure  => 'present'
  }
}
