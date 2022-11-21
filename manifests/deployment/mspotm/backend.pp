class profiles::deployment::mspotm::backend (
  String           $config_source,
  String           $version        = 'latest',
  Optional[String] $puppetdb_url   = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/mspotm-api'

  realize Apt::Source['museumpas-mspotm']

  package { 'mspotm-api':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['museumpas-mspotm']
  }

  file { 'mspotm-backend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['mspotm-api']
  }

  exec { 'mspotm composer script post-autoload-dump':
    command     => 'composer run-script post-autoload-dump',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['mspotm-api'],
    refreshonly => true,
    require     => File['mspotm-backend-config']
  }

  exec { 'run mspotm database migrations':
    command     => 'php artisan migrate',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['mspotm-api'],
    refreshonly => true,
    require     => File['mspotm-backend-config'],
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
