class profiles::uitpas::segmentatie::deployment (

  String           $version           = 'latest',
  String           $repository        = 'uitpas-segmentatie',
  String           $config_source ,
  Integer          $portbase          = 4800,
) inherits profiles {
  $secrets = lookup('vault:uitpas/segmentatie')

  $database_name = 'uitpas_segmentatie'
  $database_user = 'uitpas_segmentatie'

  realize Apt::Source[$repository]
  realize User['glassfish']

  package { 'uitpas-segmentatie':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [App['uitpas-segmentatie'], Profiles::Deployment::Versions[$title]],
  }
  file { '/opt/uitpas-segmentatie/.env':
    ensure  => 'file',
    owner   => 'glassfish',
    group   => 'glassfish',
    mode    => '0640',
    content => template($config_source),
    require => Package['uitpas-segmentatie'],
    notify  => App['uitpas-segmentatie'],
  }
  app { 'uitpas-segmentatie':
    ensure        => 'present',
    portbase      => String($portbase),
    user          => 'glassfish',
    passwordfile  => '/home/glassfish/asadmin.pass',
    contextroot   => 'segmentation',
    precompilejsp => false,
    source        => '/opt/uitpas-segmentatie/uitpas-segmentatie.war',
    envfile       => '/opt/uitpas-segmentatie/.env',
    require       => [User['glassfish'], File['/opt/uitpas-segmentatie/.env']],
  }
}
