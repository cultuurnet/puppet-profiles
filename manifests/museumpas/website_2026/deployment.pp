class profiles::museumpas::website_2026::deployment (
  String                     $config_source,
  String                     $repository         = 'museumpas-website-2026',
  String                     $version            = 'latest',
  Optional[String]           $robots_source      = undef,
  Optional[String]           $maintenance_source = undef,
  Boolean                    $run_scheduler_cron = true,
  Optional[String]           $puppetdb_url       = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits profiles {
  $basedir                 = '/var/www/museumpas'
  $secrets                 = lookup('vault:museumpas/website')
  $mount_target_dns_name   = lookup('terraform::efs::mount_target_dns_name', Optional[String], 'first', undef)
  $exec_default_attributes = {
    cwd         => $basedir,
    path        => ['/usr/local/bin', '/usr/bin', '/bin', $basedir],
    user        => 'www-data',
    environment => ['HOME=/tmp'],
    logoutput   => true,
    refreshonly => true,
    subscribe   => [Package['museumpas-website-2026'], File['museumpas-website-2026-config']],
  }

  realize User['www-data']
  realize Group['www-data']

  realize Apt::Source[$repository]

  package { 'museumpas-website-2026':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [Service['museumpas-website-2026'], Profiles::Deployment::Versions[$title]],
  }

  if $mount_target_dns_name {
    profiles::nfs::mount { "${mount_target_dns_name}:/":
      mountpoint    => "${basedir}/storage/app/public",
      mount_options => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2',
      owner         => 'www-data',
      group         => 'www-data',
      require       => [Package['museumpas-website-2026'], User['www-data'], Group['www-data']],
    }
  }

  file { 'museumpas-website-2026-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    content => template($config_source),
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['museumpas-website-2026'],
    notify  => Service['museumpas-website-2026'],
  }

  if $maintenance_source {
    file { 'museumpas-maintenance-pages':
      ensure  => 'directory',
      path    => "${basedir}/public/maintenance",
      owner   => 'www-data',
      group   => 'www-data',
      require => Package['museumpas-website-2026'],
    }

    file { 'museumpas-maintenance-page':
      ensure  => 'file',
      path    => "${basedir}/public/maintenance/maintenance.html",
      content => template($maintenance_source),
      owner   => 'www-data',
      group   => 'www-data',
      require => File['museumpas-maintenance-pages'],
    }
  }

  if $robots_source {
    file { 'museumpas-robots.txt':
      ensure  => 'file',
      path    => "${basedir}/public/robots.txt",
      content => template($robots_source),
      owner   => 'www-data',
      group   => 'www-data',
      require => Package['museumpas-website-2026'],
    }
  }

  exec { 'composer script post-autoload-dump':
    command => 'composer run-script post-autoload-dump',
    require => File['museumpas-website-2026-config'],
    *       => $exec_default_attributes,
  }

  exec { 'put museumpas in maintenance mode':
    command => 'php artisan down',
    require => Exec['composer script post-autoload-dump'],
    *       => $exec_default_attributes,
  }

  exec { 'run museumpas database migrations':
    command => 'php artisan migrate --force',
    require => Exec['put museumpas in maintenance mode'],
    *       => $exec_default_attributes,
  }

  exec { 'run museumpas database seeder':
    command => 'php artisan db:seed RoleAndPermissionSeeder --force',
    require => Exec['run museumpas database migrations'],
    *       => $exec_default_attributes,
  }

  exec { 'clear museumpas optimize cache':
    command => 'php artisan optimize:clear',
    require => Exec['run museumpas database seeder'],
    *       => $exec_default_attributes,
  }

  exec { 'clear museumpas cache':
    command => 'php artisan cache:clear',
    require => [Exec['run museumpas database migrations'], Exec['clear museumpas optimize cache']],
    *       => $exec_default_attributes,
  }

  exec { 'clear museumpas model cache':
    command => 'php artisan modelCache:clear',
    require => [Exec['run museumpas database migrations'], Exec['clear museumpas cache']],
    *       => $exec_default_attributes,
  }

  exec { 'museumpas optimize':
    command => 'php artisan optimize --except=route:cache',
    require => [Exec['run museumpas database migrations'], Exec['clear museumpas model cache']],
    *       => $exec_default_attributes,
  }

  exec { 'create storage link':
    command => 'php artisan storage:link',
    unless  => "test -L ${basedir}/public/storage",
    require => Exec['run museumpas database migrations'],
    *       => $exec_default_attributes,
  }

  exec { 'put museumpas in production mode':
    command => 'php artisan up',
    notify  => [Service['museumpas-website-2026'], Service['museumpas-website-2026-horizon']],
    require => [Exec['create storage link'], Exec['museumpas optimize']],
    *       => $exec_default_attributes,
  }

  profiles::php::fpm_service_alias { 'museumpas-website-2026': }

  service { 'museumpas-website-2026':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload museumpas-website-2026',
    require    => Profiles::Php::Fpm_service_alias['museumpas-website-2026'],
  }

  systemd::unit_file { 'museumpas-website-2026-horizon.service':
    source  => 'puppet:///modules/profiles/museumpas/website/museumpas-website-2026-horizon.service',
    enable  => true,
    active  => true,
    require => Package['museumpas-website-2026'],
  }

  service { 'museumpas-website-2026-horizon':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
    require   => Systemd::Unit_file['museumpas-website-2026-horizon.service'],
    subscribe => File['museumpas-website-2026-config'],
  }

  if $run_scheduler_cron {
    cron { 'museumpas-filament-scheduler':
      command => "cd ${basedir} && php artisan schedule:run > /dev/null 2>&1",
      require => [User['www-data'], Package['museumpas-website-2026']],
      user    => 'www-data',
    }
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url,
  }
}
