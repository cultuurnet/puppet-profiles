class profiles::uitdatabank::entry_api::deployment::instance (
  String                    $version                               = 'latest',
  String                    $repository                            = 'uitdatabank-entry-api',
  Optional[String]          $api_keys_matched_to_client_ids_source = undef,
  Enum['present', 'absent'] $amqp_listener_uitpas                  = 'present',
  Enum['present', 'absent'] $bulk_label_offer_worker               = 'present',
  Enum['present', 'absent'] $mail_worker                           = 'present',
  Integer[0]                $event_export_worker_count             = 1,
  Optional[String]          $puppetdb_url                          = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $config_dir              = '/etc/uitdatabank-entry-api'
  $basedir                 = '/var/www/udb3-backend'
  $mount_target_dns_name   = lookup('terraform::efs::mount_target_dns_name', Optional[String], 'first', undef)

  $file_default_attributes = {
                               owner   => 'www-data',
                               group   => 'www-data',
                               require => [Group['www-data'], User['www-data'], Package['uitdatabank-entry-api']],
                               notify  => Service['uitdatabank-entry-api']
                             }

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'uitdatabank-entry-api':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [Service['uitdatabank-entry-api'], Profiles::Deployment::Versions[$title]]
  }

  if $mount_target_dns_name {
    profiles::nfs::mount { "${mount_target_dns_name}:/":
      mountpoint    => "${basedir}/web/downloads",
      mount_options => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2',
      owner         => 'www-data',
      group         => 'www-data',
      require       => [Package['uitdatabank-entry-api'], User['www-data'], Group['www-data']]
    }
  }

  file { "${basedir}/config.php":
    ensure => 'file',
    source => "${config_dir}/config.php",
    *      => $file_default_attributes
  }

  file { "${basedir}/config.allow_all.php":
    ensure => 'file',
    source => "${config_dir}/config.allow_all.php",
    *      => $file_default_attributes
  }

  file { "${basedir}/config.client_permissions.php":
    ensure => 'file',
    source => "${config_dir}/config.client_permissions.php",
    *      => $file_default_attributes
  }

  file { "${basedir}/config.api_keys_matched_to_client_ids.php":
    ensure => $api_keys_matched_to_client_ids_source ? {
                undef   => 'absent',
                default => 'file'
              },
    source => "${config_dir}/config.api_keys_matched_to_client_ids.php",
    *      => $file_default_attributes
  }

  file { "${basedir}/config.kinepolis.php":
    ensure => 'file',
    source => "${config_dir}/config.kinepolis.php",
    *      => $file_default_attributes
  }

  file { "${basedir}/config.completeness.php":
    ensure => 'file',
    source => "${config_dir}/config.completeness.php",
    *      => $file_default_attributes
  }

  file { "${basedir}/config.external_id_mapping_organizer.php":
    ensure => 'file',
    source => "${config_dir}/config.external_id_mapping_organizer.php",
    *      => $file_default_attributes
  }

  file { "${basedir}/config.external_id_mapping_place.php":
    ensure => 'file',
    source => "${config_dir}/config.external_id_mapping_place.php",
    *      => $file_default_attributes
  }

  file { "${basedir}/public.pem":
    ensure => 'file',
    source => "${config_dir}/public-uitidv1.pem",
    *      => $file_default_attributes
  }

  file { "${basedir}/public-keycloak.pem":
    ensure => 'file',
    source => "${config_dir}/public-keycloak.pem",
    *      => $file_default_attributes
  }

  exec { 'uitdatabank-entry-api-db-migrate':
    command     => 'vendor/bin/doctrine-dbal --no-interaction migrations:migrate',
    cwd         => $basedir,
    path        => ['/usr/local/bin', '/usr/bin', '/bin', $basedir],
    refreshonly => true,
    subscribe   => Package['uitdatabank-entry-api'],
    notify      => Service['uitdatabank-entry-api']
  }

  profiles::php::fpm_service_alias { 'uitdatabank-entry-api': }

  service { 'uitdatabank-entry-api':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload uitdatabank-entry-api',
    subscribe  => Profiles::Php::Fpm_service_alias['uitdatabank-entry-api'],
  }

  class { 'profiles::uitdatabank::entry_api::amqp_listener_uitpas':
    ensure    => $amqp_listener_uitpas,
    basedir   => $basedir,
    subscribe => Service['uitdatabank-entry-api']
  }

  class { 'profiles::uitdatabank::entry_api::bulk_label_offer_worker':
    ensure    => $bulk_label_offer_worker,
    basedir   => $basedir,
    subscribe => Service['uitdatabank-entry-api']
  }

  class { 'profiles::uitdatabank::entry_api::mail_worker':
    ensure    => $mail_worker,
    basedir   => $basedir,
    subscribe => Service['uitdatabank-entry-api']
  }

  class { 'profiles::uitdatabank::entry_api::event_export_workers':
    count     => $event_export_worker_count,
    basedir   => $basedir,
    subscribe => Service['uitdatabank-entry-api']
  }

  class { 'profiles::uitdatabank::entry_api::logrotate':
    basedir => $basedir
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
