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
  $exec_default_attributes = {
                               cwd         => $basedir,
                               path        => ['/usr/local/bin', '/usr/bin', '/bin', $basedir],
                               user        => 'www-data',
                               environment => ['HOME=/tmp'],
                               logoutput   => true,
                               refreshonly => true,
                               subscribe   => [Package['museumpas-partner-website'], File['museumpas-partner-website-config']],
                             }

  realize User['www-data']
  realize Group['www-data']

  realize Apt::Source[$repository]

  package { 'museumpas-partner-website':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [Service['museumpas-partner-website'], Profiles::Deployment::Versions[$title]]
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

# TODO: NFS required?
#
#   if $mount_target_dns_name {
#     profiles::nfs::mount { "${mount_target_dns_name}:/":
#       mountpoint    => "${basedir}/web/documents",
#       mount_options => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2',
#       owner         => 'www-data',
#       group         => 'www-data',
#       require       => [Package['museumpas-partner-website'], User['www-data'], Group['www-data']]
#     }
#   }
# 
# TODO: which php post install commands required?
#
#   exec { 'composer script post-autoload-dump':
#     command => 'composer run-script post-autoload-dump',
#     require => File['museumpas-website-config'],
#     *       => $exec_default_attributes
#   }
# 
#   exec { 'run museumpas database migrations':
#     command => 'php artisan migrate --force',
#     require => [File['museumpas-website-config'], Exec['put museumpas in maintenance mode']],
#     *       => $exec_default_attributes
#   }
#
#   ...?

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

