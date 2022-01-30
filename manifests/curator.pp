class profiles::curator (
  String           $articlelinker_config_source,
  String           $articlelinker_publishers_source,
  String           $api_config_source,
  String           $api_hostname,
  String           $articlelinker_version             = 'latest',
  Optional[String] $articlelinker_env_defaults_source = undef,
  Boolean          $articlelinker_service_manage      = true,
  String           $articlelinker_service_ensure      = 'running',
  Boolean          $articlelinker_service_enable      = true,
  String           $api_version                       = 'latest',
  Boolean          $api_local_database                = false,
  Optional[String] $api_local_database_name           = undef,
  Optional[String] $api_local_database_user           = undef,
  Optional[String] $api_local_database_password       = undef,
  Optional[String] $puppetdb_url                      = undef
) inherits ::profiles {

  # TODO: unit tests
  # TODO: apache vhosts (articlelinker & api)
  # TODO: non-local DB
  # TODO: php
  # TODO: better solution for certificates
  # TODO: firewall rules

  $api_basedir = '/var/www/curator-api'
  $articlelinker_basedir = '/var/www/curator-articlelinker'

  #include php
  #include apache
  #include mysql::server ??
  #include supervisor

  if $api_local_database {
    mysql::db { $api_local_database_name:
      user     => $api_local_database_user,
      password => $api_local_database_password,
      host     => 'localhost',
      grant    => ['ALL']
    }
  }

#   apache::vhost { "${api_hostname}_80":
#     servername      => $api_hostname,
#     docroot         => "${api_basedir}/public",
#     manage_docroot  => false,
#     request_headers => [ 'unset Proxy early'],
#     port            => '80',
#     redirect_source => '/',
#     redirect_dest   => "https://${api_hostname}/",
#     redirect_status => 'permanent'
#   }
#
#   apache::vhost { "${api_hostname}_443":
#     servername      => $api_hostname,
#     docroot         => "${api_basedir}/public",
#     manage_docroot  => false,
#     request_headers => [ 'unset Proxy early'],
#     port            => '443',
#     ssl             => true,
#     ssl_cert        => '/etc/ssl/certs/wildcard.uitdatabank.dev.cert.pem',
#     ssl_chain       => '/etc/ssl/certs/intermediate.cert.pem',
#     ssl_key         => '/etc/ssl/private/wildcard.uitdatabank.dev.key.pem',
#     ssl_ca          => '/etc/ssl/certs/ca.cert.pem',
#     directories        => [ {
#       'path'           => '/',
#       'provider'       => 'location',
#       'options'        => [ 'Indexes', 'FollowSymLinks', 'MultiViews', 'ExecCGI'],
#       'allow_override' => [ 'All']
#     } ],
#     require         => [
#       File['/etc/ssl/certs/wildcard.uitdatabank.dev.cert.pem'],
#       File['/etc/ssl/certs/intermediate.cert.pem'],
#       File['/etc/ssl/private/wildcard.uitdatabank.dev.key.pem'],
#       File['/etc/ssl/certs/ca.cert.pem']
#     ]
#   }

  unless any2bool($facts['noop_deploy']) {
    file { $api_basedir:
      ensure => 'directory',
      before => Class['::profiles::deployment::curator::api']
    }

    #File[$api_basedir] -> Apache::Vhost["${api_hostname}_80"]
    #File[$api_basedir] -> Apache::Vhost["${api_hostname}_443"]

    class { 'profiles::deployment::curator::articlelinker':
      config_source       => $articlelinker_config_source,
      publishers_source   => $articlelinker_publishers_source,
      version             => $articlelinker_version,
      env_defaults_source => $articlelinker_env_defaults_source,
      service_manage      => $articlelinker_service_manage,
      service_ensure      => $articlelinker_service_ensure,
      service_enable      => $articlelinker_service_enable,
      puppetdb_url        => $puppetdb_url
    }

    class { 'profiles::deployment::curator::api':
      config_source   => $api_config_source,
      version         => $api_version,
      puppetdb_url    => $puppetdb_url
    }

    if $api_local_database {
      Mysql::Db[$api_local_database_name] -> Class['::profiles::deployment::curator::api']
    }

    Class['php'] -> Class['profiles::deployment::curator::api']
  }
}
