class profiles::deployment::infrastructure (
  String           $version      = 'latest',
  Optional[String] $puppetdb_url = undef
) inherits ::profiles {

  include ::profiles::puppetserver::cache_clear

  realize Apt::Source['publiq-infrastructure']

  package { 'infrastructure-publiq':
    ensure  => $version,
    notify  => Class['profiles::puppetserver::cache_clear'],
    require => Apt::Source['publiq-infrastructure']
  }

  profiles::deployment::versions { $title:
    project         => 'infrastructure',
    packages        => 'infrastructure-publiq',
    destination_dir => '/var/run',
    puppetdb_url    => $puppetdb_url,
    require         => Class['profiles::puppetserver::cache_clear']
  }
}
