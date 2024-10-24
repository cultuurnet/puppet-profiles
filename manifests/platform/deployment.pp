class profiles::platform::deployment (
  String                     $config_source,
  String                     $admin_users_source,
  String                     $version            = 'latest',
  String                     $repository         = 'platform-api',
  Optional[String]           $puppetdb_url       = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir                 = '/var/www/platform-api'
  $exec_default_attributes = {
                               cwd         => $basedir,
                               path        => ['/usr/local/bin', '/usr/bin', '/bin'],
                               user        => 'www-data',
                               environment => ['HOME=/'],
                               logoutput   => true,
                               refreshonly => true,
                               subscribe   => [Package['platform-api'], File['platform-api-config'], File['platform-api-admin-users']]
                             }

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'platform-api':
    ensure  => $version,
    require => Apt::Source['platform-api'],
    notify  => [Service['platform-api'], Service['platform-api-horizon'], Profiles::Deployment::Versions[$title]]
  }

  file { 'platform-api-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => [Package['platform-api'], Group['www-data'], User['www-data']],
    notify  => [Service['platform-api'], Service['platform-api-horizon']]
  }

  file { 'platform-api-admin-users':
    ensure  => 'file',
    path    => "${basedir}/nova_users.php",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $admin_users_source,
    require => [Package['platform-api'], Group['www-data'], User['www-data']],
    notify  => [Service['platform-api'], Service['platform-api-horizon']]
  }

  exec { 'run platform database migrations':
    command     => 'php artisan migrate --force',
    *           => $exec_default_attributes
  }

  exec { 'run platform database seed':
    command     => 'php artisan db:seed --force',
    require     => Exec['run platform database migrations'],
    *           => $exec_default_attributes
  }

  exec { 'run platform cache clear':
    command     => 'php artisan optimize:clear',
    require     => Exec['run platform database seed'],
    *           => $exec_default_attributes
  }

  exec { 'run platform optimize':
    command     => 'php artisan optimize',
    require     => Exec['run platform cache clear'],
    *           => $exec_default_attributes
  }

  profiles::php::fpm_service_alias { 'platform-api': }

  service { 'platform-api':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload platform-api',
    require    => Profiles::Php::Fpm_service_alias['platform-api'],
  }

  systemd::unit_file { 'platform-api-horizon.service':
    source  => 'puppet:///modules/profiles/platform/platform-api-horizon.service',
    enable  => true,
    active  => true,
    require => Package['platform-api']
  }

  service { 'platform-api-horizon':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
    require   => Systemd::Unit_file['platform-api-horizon.service']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
