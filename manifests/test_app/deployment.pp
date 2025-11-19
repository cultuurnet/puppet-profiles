class profiles::uitpas::test_app::deployment (
  String           $version       = 'latest',
  String           $repository    = 'test-app',
  Optional[String] $puppetdb_url  = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/test-app'

  realize Apt::Source[$repository]

  package { 'test-app':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source[$repository]
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
