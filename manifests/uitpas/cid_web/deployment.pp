class profiles::uitpas::cid_web::deployment (
  String                     $config_source,
  String                     $version       = 'latest',
  String                     $repository    = 'uitpas-cid-web',
  Optional[String]           $puppetdb_url  = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitpas-cid-web'
  $secrets = lookup('vault:uitpas/cid-web')

  realize Apt::Source[$repository]

  package { 'uitpas-cid-web':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source[$repository]
  }

  file { 'uitpas-cid-web-config':
    ensure  => 'file',
    path    => "${basedir}/config.json",
    owner   => 'www-data',
    group   => 'www-data',
    content  => template($config_source),
    require => Package['uitpas-cid-web']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
