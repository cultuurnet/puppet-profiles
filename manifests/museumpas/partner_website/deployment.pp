class profiles::museumpas::partner_website::deployment (
  String                     $config_source,
  String                     $maintenance_source,
  String                     $repository         = 'museumpas-partner-website',
  String                     $version            = 'latest',
  Optional[String]           $robots_source      = undef,
  Boolean                    $run_scheduler_cron = true,
  Optional[String]           $puppetdb_url       = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir                 = '/var/www/museumpas-partner'
  $mount_target_dns_name   = lookup('terraform::efs::mount_target_dns_name', Optional[String], 'first', undef)

  realize User['www-data']
  realize Group['www-data']

  realize Apt::Source[$repository]

  package { 'museumpas-partner-website':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [Service['museumpas-partner-website'], Profiles::Deployment::Versions[$title]]
  }

  if $mount_target_dns_name {
    profiles::nfs::mount { "${mount_target_dns_name}:/":
      mountpoint    => "${basedir}/web/documents",
      mount_options => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2',
      owner         => 'www-data',
      group         => 'www-data',
      require       => [Package['museumpas-partner-website'], User['www-data'], Group['www-data']]
    }
  }

  file { 'museumpas-partner-website-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    source  => $config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['museumpas-partner-website'],
    notify  => Service['museumpas-partner-website']
  }

  file { 'museumpas-partner-maintenance-pages':
    ensure  => 'directory',
    path    => "${basedir}/web/maintenance",
    recurse => true,
    source  => $maintenance_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['museumpas-partner-website'],
  }

  if $robots_source {
    file { 'museumpas-robots.txt':
      ensure  => 'file',
      path    => "${basedir}/web/robots.txt",
      source  => $robots_source,
      owner   => 'www-data',
      group   => 'www-data',
      require => Package['museumpas-partner-website'],
    }
  }

  profiles::php::fpm_service_alias { 'museumpas-partner-website': }

  service { 'museumpas-partner-website':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload museumpas-partner-website',
    require    => Profiles::Php::Fpm_service_alias['museumpas-partner-website'],
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }

  Class['profiles::php'] -> Class['profiles::museumpas::partner_website']
}

