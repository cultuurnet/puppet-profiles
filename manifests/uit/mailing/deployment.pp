class profiles::uitid::mailing::deployment (

  String           $version           = 'latest',
  String           $repository        = 'uitid-mailing',
  String           $config_source ,
  Integer          $portbase          = 4800,
) inherits profiles {

  $database_name = 'uit_maling'
  $database_user = 'uit_maling'

  realize Apt::Source[$repository]
  realize User['glassfish']

  package { 'uitid-mailing':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [App['uitid-mailing']],
  }
  app { 'uitid-mailing':
    ensure        => 'present',
    portbase      => String($portbase),
    user          => 'glassfish',
    passwordfile  => '/home/glassfish/asadmin.pass',
    contextroot   => 'mailing',
    precompilejsp => false,
    source        => '/opt/uitid-mailing/uitid-mailing.war',
    require       => [User['glassfish']],
  }
}
