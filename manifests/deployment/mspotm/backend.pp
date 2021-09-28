class profiles::deployment::mspotm::backend (
  String           $config_source,
  String           $version        = 'latest',
  Optional[String] $puppetdb_url   = undef
) inherits ::profiles {

  include ::profiles::deployment::mspotm

  $basedir = '/var/www/mspotm-backend'

  realize Profiles::Apt::Update['publiq-mspotm']

  package { 'mspotm-backend':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-mspotm']
  }

  file { 'mspotm-backend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['mspotm-backend']
  }

  exec { 'mspotm composer script post-autoload-dump':
    command     => 'composer run-script post-autoload-dump',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['mspotm-backend'],
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
    subscribe   => Package['mspotm-backend'],
    refreshonly => true,
    require     => File['mspotm-backend-config'],
  }

  profiles::deployment::versions { $title:
    project      => 'mspotm',
    packages     => 'mspotm-backend',
    puppetdb_url => $puppetdb_url
  }
}
