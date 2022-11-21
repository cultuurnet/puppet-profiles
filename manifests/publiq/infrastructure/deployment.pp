class profiles::publiq::infrastructure::deployment (
  String           $version      = 'latest',
  Optional[String] $puppetdb_url = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  include ::profiles::puppetserver::cache_clear

  realize Apt::Source['publiq-infrastructure']

  package { 'publiq-infrastructure':
    ensure  => $version,
    notify  => [ Class['profiles::puppetserver::cache_clear'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source['publiq-infrastructure']
  }

  profiles::deployment::versions { $title:
    puppetdb_url    => $puppetdb_url,
    require         => Class['profiles::puppetserver::cache_clear']
  }
}
