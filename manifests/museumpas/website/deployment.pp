class profiles::museumpas::website::deployment (
  String                     $config_source,
  String                     $maintenance_source,
  String                     $repository         = 'museumpas-website',
  Enum['running', 'stopped'] $service_status     = 'running',
  String                     $version            = 'latest',
  Optional[String]           $robots_source      = undef,
  Boolean                    $run_scheduler_cron = true,
  Optional[String]           $puppetdb_url       = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir                 = '/var/www/museumpas'
  $mount_target_dns_name   = lookup('terraform::efs::mount_target_dns_name', Optional[String], 'first', undef)
  $exec_default_attributes = {
                               cwd         => $basedir,
                               path        => ['/usr/local/bin', '/usr/bin', '/bin', $basedir],
                               user        => 'www-data',
                               environment => ['HOME=/tmp'],
                               logoutput   => true,
                               refreshonly => true,
                               subscribe   => [Package['museumpas-website'], File['museumpas-website-config']],
                             }

  realize User['www-data']
  realize Group['www-data']

  realize Apt::Source[$repository]

  package { 'museumpas-website':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [Service['museumpas-website'], Profiles::Deployment::Versions[$title]]
  }

  if $mount_target_dns_name {
    profiles::nfs::mount { "${mount_target_dns_name}:/":
      mountpoint    => "${basedir}/storage/app/public",
      mount_options => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2',
      owner         => 'www-data',
      group         => 'www-data',
      require       => [Package['museumpas-website'], User['www-data'], Group['www-data']]
    }
  }

  file { 'museumpas-website-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    source  => $config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['museumpas-website'],
    notify  => Service['museumpas-website']
  }

  file { 'museumpas-maintenance-pages':
    ensure  => 'directory',
    path    => "${basedir}/public/maintenance",
    recurse => true,
    source  => $maintenance_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['museumpas-website'],
  }

  if $robots_source {
    file { 'museumpas-robots.txt':
      ensure  => 'file',
      path    => "${basedir}/public/robots.txt",
      source  => $robots_source,
      owner   => 'www-data',
      group   => 'www-data',
      require => Package['museumpas-website'],
    }
  }

  exec { 'composer script post-autoload-dump':
    command => 'composer run-script post-autoload-dump',
    require => File['museumpas-website-config'],
    *       => $exec_default_attributes
  }

  exec { 'put museumpas in maintenance mode':
    command => 'php artisan down',
    require => [File['museumpas-website-config'], Exec['composer script post-autoload-dump']],
    *       => $exec_default_attributes
  }

  exec { 'run museumpas database migrations':
    command => 'php artisan migrate --force',
    require => [File['museumpas-website-config'], Exec['put museumpas in maintenance mode']],
    *       => $exec_default_attributes
  }

  exec { 'run museumpas database seeder':
    command => 'php artisan db:seed RoleAndPermissionSeeder --force',
    require => [File['museumpas-website-config'], Exec['run museumpas database migrations']],
    *       => $exec_default_attributes
  }

  exec { 'clear museumpas optimize cache':
    command => 'php artisan optimize:clear',
    require => [File['museumpas-website-config'], Exec['run museumpas database seeder']],
    *       => $exec_default_attributes
  }

  exec { 'clear museumpas cache':
    command => 'php artisan cache:clear',
    require => [File['museumpas-website-config'], Exec['run museumpas database migrations'], Exec['clear museumpas optimize cache']],
    *       => $exec_default_attributes
  }

  exec { 'clear museumpas model cache':
    command => 'php artisan modelCache:clear',
    require => [File['museumpas-website-config'], Exec['run museumpas database migrations'], Exec['clear museumpas cache']],
    *       => $exec_default_attributes
  }

  exec { 'create storage link':
    command => 'php artisan storage:link',
    unless  => "test -L ${basedir}/public/storage",
    require => [File['museumpas-website-config'], Exec['run museumpas database migrations']],
    *       => $exec_default_attributes
  }

  exec { 'put museumpas in production mode':
    command => 'php artisan up',
    notify  => [Service['museumpas-website'], Service['museumpas-website-horizon']],
    require => [File['museumpas-website-config'], Exec['create storage link'], Exec['clear museumpas model cache']],
    *       => $exec_default_attributes
  }

  profiles::php::fpm_service_alias { 'museumpas-website': }

  service { 'museumpas-website':
    ensure    => $service_status,
    hasstatus => true,
    restart   => 'reload',
    require   => Profiles::Php::Fpm_service_alias['museumpas-website'],
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 }
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
    require   => Systemd::Unit_file['museumpas-website-horizon.service'],
    subscribe => File['museumpas-website-config']
  }

  if $run_scheduler_cron {
    cron { 'museumpas-filament-scheduler':
      command     => "cd ${basedir} && php artisan schedule:run > /dev/null 2>&1",
      require     => [User['www-data'], Package['museumpas-website']],
      user        => 'www-data'
    }
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }

  Class['profiles::php'] -> Class['profiles::museumpas::website']
}

