class profiles::projectaanvraag::api::deployment (
  String           $config_source,
  String           $integration_types_source,
  String           $user_roles_source,
  String           $version                  = 'latest',
  String           $repository               = 'projectaanvraag-api',
  String           $database_name            = 'projectaanvraag',
  Optional[String] $puppetdb_url             = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir                 = '/var/www/projectaanvraag-api'
  $secrets                 = lookup('vault:projectaanvraag/api')
  $file_default_attributes = {
                               ensure  => 'file',
                               owner   => 'www-data',
                               group   => 'www-data',
                               require => [Group['www-data'], User['www-data'], Package['projectaanvraag-api']],
                               notify  => Service['projectaanvraag-api']
                             }
  $exec_default_attributes = {
                               cwd       => $basedir,
                               path      => ['/usr/bin', '/bin', $basedir],
                               logoutput => 'on_failure'
                             }

  realize Group['www-data']
  realize User['www-data']
  realize Apt::Source[$repository]

  package { 'projectaanvraag-api':
    ensure  => $version,
    notify  => [Service['projectaanvraag-api'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'projectaanvraag-api-config':
    path    => "${basedir}/config.yml",
    content => template($config_source),
    *       => $file_default_attributes
  }

  file { 'projectaanvraag-api-integration-types':
    path    => "${basedir}/integration_types.yml",
    content => template($integration_types_source),
    *       => $file_default_attributes
  }

  file { 'projectaanvraag-api-user-roles':
    path    => "${basedir}/user_roles.yml",
    content => template($user_roles_source),
    *       => $file_default_attributes
  }

  exec { 'projectaanvraag-api-cache-clear':
    command     => 'bin/console projectaanvraag:cache-clear',
    refreshonly => true,
    subscribe   => [File['projectaanvraag-api-config'], File['projectaanvraag-api-integration-types'], File['projectaanvraag-api-user-roles'], Package['projectaanvraag-api']],
    *           => $exec_default_attributes
  }

  exec { 'projectaanvraag-api-db-install':
    command   => 'bin/console orm:schema-tool:create',
    onlyif    => "test 0 -eq $(mysql --defaults-extra-file=/root/.my.cnf -s --skip-column-names -e 'select count(table_name) from information_schema.tables where table_schema = \"${database_name}\";')",
    subscribe => Package['projectaanvraag-api'],
    *         => $exec_default_attributes
  }

  exec { 'projectaanvraag-api-clear-metadata-cache':
    command     => 'bin/console orm:clear-cache:metadata',
    refreshonly => true,
    require     => Exec['projectaanvraag-api-db-install'],
    subscribe   => Package['projectaanvraag-api'],
    *           => $exec_default_attributes
  }

  exec { 'projectaanvraag-api-db-migrate':
    command     => 'bin/console orm:schema-tool:update --force',
    refreshonly => true,
    require     => Exec['projectaanvraag-api-clear-metadata-cache'],
    subscribe   => Package['projectaanvraag-api'],
    *           => $exec_default_attributes
  }

  profiles::php::fpm_service_alias { 'projectaanvraag-api': }

  service { 'projectaanvraag-api':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload projectaanvraag-api',
    require    => Profiles::Php::Fpm_service_alias['projectaanvraag-api']
  }

  class { 'profiles::projectaanvraag::api::logrotate':
    basedir => $basedir
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
