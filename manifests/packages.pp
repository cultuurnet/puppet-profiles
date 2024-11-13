class profiles::packages inherits ::profiles {

  @package { 'composer':
    ensure  => 'absent'
  }

  @package { 'composer1':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  @package { 'composer2':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  @package { 'drush':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
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

  @package { 'graphviz':
    ensure => 'present'
  }

  @package { 'ca-certificates-publiq':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  @package { 'jq':
    ensure => 'present'
  }

  @package { 'gcsfuse':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  @package { 'liquibase':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  @package { 'mysql-connector-j':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  @package { 'yarn':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  @package { 'bundler':
    ensure => 'present'
  }

  @package { 'qemu-user-static':
    ensure  => 'present'
  }

  @package { 'build-essential':
    ensure  => 'present'
  }

  @package { 'mysql-client':
    ensure  => 'present'
  }

  @package { 'nfs-common':
    ensure  => 'present'
  }

  @package { 'iftop':
    ensure  => 'present'
  }

  @package { 'borgbackup':
    ensure  => 'present'
  }

  @package { 'borgmatic':
    ensure  => 'present'
  }

  @package { 'rubygem-puppetdb-cli':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  @package { 'kubectl':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  @package { 'argocd':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  @package { 'google-cloud-cli':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  @package { 'graphite-web':
    ensure  => 'present'
  }

  @package { 'graphite-carbon':
    ensure  => 'present'
  }

  @package { 'uwsgi':
    ensure  => 'present'
  }

  @package { 'uwsgi-plugin-python3':
    ensure  => 'present'
  }

  @package { 'rubygem-angular-config':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  # Realize a list of 'default' packages on all servers
  realize Package['jq']
  realize Package['iftop']
}
