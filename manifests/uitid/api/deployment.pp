class profiles::uitid::api::deployment (
  String           $version      = 'latest',
  String           $repository   = 'uitid-api',
  Integer          $portbase     = 4800,
  Optional[String] $puppetdb_url = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits profiles {

  realize Apt::Source[$repository]
  realize User['glassfish']

  package { 'uitid-api':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [App['uitid-api'], Profiles::Deployment::Versions[$title]]
  }

  app { 'uitid-api':
    ensure        => 'present',
    portbase      => String($portbase),
    user          => 'glassfish',
    passwordfile  => '/home/glassfish/asadmin.pass',
    contextroot   => 'uitid',
    precompilejsp => false,
    source        => '/opt/uitid-api/uitid-api.war',
    require       => User['glassfish']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
