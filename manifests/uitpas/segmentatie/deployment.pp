class profiles::uitpas::segmentatie::deployment (
  String           $database_password,
  String           $database_host                   = '127.0.0.1',
  String          $config_source,
  String           $version                         = 'latest',
  String           $repository                      = 'uitpas-segmentatie',
  Integer          $portbase                        = 4800,
  Boolean                        $deployment        = true,
  Optional[String]               $initial_heap_size = undef,
  Optional[String]               $maximum_heap_size = undef,
  Boolean                        $jmx               = true,
  Integer                        $portbase          = 4800,
  Enum['running', 'stopped']     $service_status    = 'running',
  Hash                           $settings             = {}
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
