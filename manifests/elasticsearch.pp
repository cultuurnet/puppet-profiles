class profiles::elasticsearch (
  String $version = '5.2.2'
) inherits ::profiles {

  $major_version = split($version, /\./)[0]

  contain ::profiles::java

  realize Apt::Source["elasticsearch"]
  realize Apt::Source["elastic-${major_version}.x"]

  # TODO: parameterize this profile (version, ...)
  # TODO: add /data/backups/elasticsearch directory
  # TODO: add snapshot repositories and backup schedule (maybe in product profile)
  # TODO: unit tests
  # TODO: firewall rules

  file { '/data/elasticsearch':
    ensure => 'directory',
    before => Class['elasticsearch']
  }

  sysctl { 'vm.max_map_count':
    value  => '262144',
    before => Class['elasticsearch']
  }

  class { '::elasticsearch':
    version           => $version,
    manage_repo       => false,
    api_timeout       => 30,
    restart_on_change => true,
    instances         => {},
    require           => [ Apt::Source["elastic-${major_version}.x"], Class['::profiles::java']]
  }
}
