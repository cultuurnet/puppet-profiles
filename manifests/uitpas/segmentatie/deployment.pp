class profiles::uitpas::segmentatie::deployment (
  String           $database_password,
  String           $database_host     = '127.0.0.1',
  String           $version           = 'latest',
  String           $repository        = 'uitpas-segmentatie',
  Integer          $portbase          = 4800,
  Optional[String] $puppetdb_url      = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $database_name = 'uitpas_segmentatie'
  $database_user = 'uitpas_segmentatie'

  realize Apt::Source[$repository]
  realize User['glassfish']

  package { 'uitpas-segmentatie':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [App['uitpas-segmentatie'], Profiles::Deployment::Versions[$title]]
  }

  app { 'uitpas-segmentatie':
    ensure        => 'present',
    portbase      => String($portbase),
    user          => 'glassfish',
    passwordfile  => '/home/glassfish/asadmin.pass',
    contextroot   => 'uitid',
    precompilejsp => false,
    source        => '/opt/uitpas-segmentatie/uitpas-segmentatie.war',
    require       => User['glassfish']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
