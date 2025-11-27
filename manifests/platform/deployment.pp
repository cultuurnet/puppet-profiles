class profiles::platform::deployment (
  String           $config_source,
  String           $admin_users_source,
  String           $version                     = 'latest',
  String           $repository                  = 'platform-api',
  Boolean          $search_expired_integrations = false,
  Optional[String] $puppetdb_url                = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir                 = '/var/www/platform-api'
  $secrets = lookup('vault:platform')
  $exec_default_attributes = {
                               cwd         => $basedir,
                               path        => ['/usr/local/bin', '/usr/bin', '/bin'],
                               user        => 'www-data',
                               environment => ['HOME=/'],
                               logoutput   => true,
                               refreshonly => true,
                               before      => [Service['platform-api'], Service['platform-api-horizon']]
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
    content  => template($config_source),
    require => [Package['platform-api'], Group['www-data'], User['www-data']],
    notify  => [Service['platform-api'], Service['platform-api-horizon']]
  }

  file { 'platform-api-admin-users':
    ensure  => 'file',
    path    => "${basedir}/nova_users.php",
    owner   => 'www-data',
    group   => 'www-data',
    content  => template($admin_users_source),
    require => [Package['platform-api'], Group['www-data'], User['www-data']],
    notify  => [Service['platform-api'], Service['platform-api-horizon']]
  }

  exec { 'run platform database migrations':
    command     => 'php artisan migrate --force',
    subscribe   => Package['platform-api'],
    *           => $exec_default_attributes
  }

  exec { 'run platform database seed':
    command     => 'php artisan db:seed --force',
    require     => Exec['run platform database migrations'],
    subscribe   => Package['platform-api'],
    *           => $exec_default_attributes
  }

  exec { 'run platform cache clear':
    command     => 'php artisan optimize:clear',
    require     => Exec['run platform database seed'],
    subscribe   => [Package['platform-api'], File['platform-api-config'], File['platform-api-admin-users']],
    *           => $exec_default_attributes
  }

  exec { 'run platform optimize':
    command     => 'php artisan optimize',
    require     => Exec['run platform cache clear'],
    subscribe   => [Package['platform-api'], File['platform-api-config'], File['platform-api-admin-users']],
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

  cron { 'platform-search-expired-integrations':
    ensure      => $search_expired_integrations ? {
                     true  => 'present',
                     false => 'absent'
                   },
    command     => "cd ${basedir}; php artisan integration:search-expired-integrations --force",
    environment => ['MAILTO=infra+cron@publiq.be'],
    user        => 'www-data',
    hour        => '0',
    minute      => '0',
    require     => Package['platform-api']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
