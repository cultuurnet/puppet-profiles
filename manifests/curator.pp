class profiles::curator (
  String           $articlelinker_config_source,
  String           $articlelinker_publishers_source,
  String           $articlelinker_version             = 'latest',
  Optional[String] $articlelinker_env_defaults_source = undef,
  Boolean          $articlelinker_service_manage      = true,
  String           $articlelinker_service_ensure      = 'running',
  Boolean          $articlelinker_service_enable      = true,
) inherits ::profiles {

  # TODO: unit tests
  # TODO: apache vhost (articlelinker)
  # TODO: firewall rules

  $articlelinker_basedir = '/var/www/curator-articlelinker'

  unless any2bool($facts['noop_deploy']) {
    file { $articlelinker_basedir:
      ensure => 'directory',
      before => Class['::profiles::deployment::curator::articlelinker']
    }

    class { 'profiles::deployment::curator::articlelinker':
      config_source       => $articlelinker_config_source,
      publishers_source   => $articlelinker_publishers_source,
      version             => $articlelinker_version,
      env_defaults_source => $articlelinker_env_defaults_source,
      service_manage      => $articlelinker_service_manage,
      service_ensure      => $articlelinker_service_ensure,
      service_enable      => $articlelinker_service_enable
    }
  }
}
