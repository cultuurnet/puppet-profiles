class profiles::deployment::appconfig (
  String           $version      = 'latest',
  Optional[String] $puppetdb_url = undef
) inherits ::profiles {

  include ::profiles::puppetserver::cache_clear

  realize Apt::Source['publiq-appconfig']

  package { 'appconfig-publiq':
    ensure  => $version,
    notify  => Class['profiles::puppetserver::cache_clear'],
    require => Apt::Source['publiq-appconfig']
  }

  profiles::deployment::versions { $title:
    project         => 'appconfig',
    packages        => 'appconfig-publiq',
    destination_dir => '/var/run',
    puppetdb_url    => $puppetdb_url,
    require         => Class['profiles::puppetserver::cache_clear']
  }
}
