class profiles::publiq::infrastructure::deployment (
  String           $version      = 'latest',
  String           $repository   = 'publiq-infrastructure',
  Optional[String] $puppetdb_url = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  include ::profiles::puppet::puppetserver::cache_clear

  realize Apt::Source[$repository]

  package { 'publiq-infrastructure':
    ensure  => $version,
    notify  => [ Class['profiles::puppet::puppetserver::cache_clear'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  profiles::deployment::versions { $title:
    puppetdb_url    => $puppetdb_url,
    require         => Class['profiles::puppet::puppetserver::cache_clear']
  }
}
