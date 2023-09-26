class profiles::museumpas::website::deployment (
  String $repository                         = 'museumpas-website',
  Enum['running', 'stopped'] $service_status = 'running',
  $config_source,
  $maintenance_source,
  $version                                   = 'latest',
  $robots_source                             = undef,
  $noop_deploy                               = false,
  $puppetdb_url                              = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/museumpas'

  realize Apt::Source[$repository]

  package { 'museumpas-website':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => Profiles::Deployment::Versions[$title],
    noop    => $noop_deploy
  }

  file { 'museumpas-website-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    source  => $config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => 'Package[museumpas-website]',
    noop    => $noop_deploy
  }

  file { 'museumpas-maintenance-pages':
    ensure  => 'directory',
    path    => "${basedir}/public/maintenance",
    recurse => true,
    source  => $maintenance_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => 'Package[museumpas-website]',
    noop    => $noop_deploy
  }

  if $robots_source {
    file { 'museumpas-robots.txt':
      ensure  => 'file',
      path    => "${basedir}/public/robots.txt",
      source  => $robots_source,
      owner   => 'www-data',
      group   => 'www-data',
      require => 'Package[museumpas-website]',
      noop    => $noop_deploy
    }
  }

  exec { 'composer script post-autoload-dump':
    command     => '/usr/bin/composer run-script post-autoload-dump',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
    user        => 'www-data',
    environment => [ 'HOME=/tmp'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => File['museumpas-website-config'],
    noop        => $noop_deploy
  }

  exec { 'put museumpas in maintenance mode':
    command     => 'php artisan down',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['composer script post-autoload-dump']],
    noop        => $noop_deploy
  }

  exec { 'run museumpas database migrations':
    command     => 'php artisan migrate --force',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['put museumpas in maintenance mode'] ],
    noop        => $noop_deploy
  }

  exec { 'clear museumpas cache':
    command     => 'php artisan optimize:clear',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['run museumpas database migrations'] ],
    noop        => $noop_deploy
  }

  exec { 'clear museumpas model cache':
    command     => 'php artisan -q modelCache:clear',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['run museumpas database migrations'], Exec['clear museumpas cache'] ],
    noop        => $noop_deploy
  }

  exec { 'create storage link':
    command     => 'php artisan storage:link',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    logoutput   => true,
    unless      => "test -L ${basedir}/public/storage",
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['run museumpas database migrations'] ],
    noop        => $noop_deploy
  }

  exec { 'put museumpas in production mode':
    command     => 'php artisan up',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['create storage link'], Exec['clear museumpas model cache'] ],
    noop        => $noop_deploy
  }

  systemd::unit_file { 'museumpas-website-horizon.service':
    source  => 'puppet:///modules/profiles/museumpas/website/museumpas-website-horizon.service',
    enable  => true,
    active  => true,
    require => Package['museumpas-website']
  }

  service { 'museumpas-website-horizon':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    require   => [Systemd::Unit_file['museumpas-website-horizon.service']]
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }

  Class['profiles::php'] -> Class['profiles::museumpas::website']
}

