class profiles::platform::deployment (
  String                     $config_source,
  String                     $version        = 'latest',
  String                     $repository     = 'platform-api',
  Enum['running', 'stopped'] $service_status = 'running',
  Optional[String]           $puppetdb_url   = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/platform-api'

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

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
    require => [Package['platform-api'], Group['www-data'], User['www-data']]
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

  exec { 'run platform database seed':
    command     => 'php artisan db:seed --force',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['platform-api'],
    refreshonly => true,
    require     => [File['platform-api-config'],Exec['run platform database migrations']],
  }

  exec { 'run platform cache clear':
    command     => 'php artisan cache:clear',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['platform-api'],
    refreshonly => true,
    require     => [File['platform-api-config'],Exec['run platform database migrations']],
  }

  exec { 'run platform route cache':
    command     => 'php artisan route:cache',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['platform-api'],
    refreshonly => true,
    require     => [File['platform-api-config'],Exec['run platform cache clear']],
  }

  exec { 'run platform config cache':
    command     => 'php artisan config:cache',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['platform-api'],
    refreshonly => true,
    require     => [File['platform-api-config'],Exec['run platform route cache']],
  }

  exec { 'run platform view cache':
    command     => 'php artisan view:cache',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['platform-api'],
    refreshonly => true,
    require     => [File['platform-api-config'],Exec['run platform config cache']],
  }

  systemd::unit_file { 'platform-api-horizon.service':
    source  => 'puppet:///modules/profiles/platform/platform-api-horizon.service',
    enable  => true,
    active  => true,
    require => Package['platform-api']
  }

  service { 'platform-api-horizon':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    require   => [Systemd::Unit_file['platform-api-horizon.service']]
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
