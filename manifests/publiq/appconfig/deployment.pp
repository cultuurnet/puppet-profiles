class profiles::publiq::appconfig::deployment (
  String           $version      = 'latest',
  Optional[String] $puppetdb_url = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  include ::profiles::puppet::puppetserver::cache_clear

  realize Apt::Source['publiq-appconfig']

  package { 'publiq-appconfig':
    ensure  => $version,
    notify  => [ Class['profiles::puppet::puppetserver::cache_clear'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source['publiq-appconfig']
  }

  profiles::deployment::versions { $title:
    puppetdb_url    => $puppetdb_url,
    require         => Class['profiles::puppet::puppetserver::cache_clear']
  }
}
