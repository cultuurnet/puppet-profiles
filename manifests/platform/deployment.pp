class profiles::platform::deployment (
  String           $config_source,
  String           $version       = 'latest',
  Optional[String] $puppetdb_url  = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/platform-api'

  realize Apt::Source['platform-api']

  package { 'platform-api':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['platform-api']
  }

  file { 'platform-api-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['platform-api-config']
  }

  exec { 'run platform database migrations':
    command     => 'php artisan migrate --force',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['platform-api'],
    refreshonly => true,
    require     => File['platform-api-config'],
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
