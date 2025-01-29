class profiles::testproject::testcomponent (
  String $config_source,
) inherits ::profiles {

  $secrets = lookup('vault:testproject/testcomponent')

  file { 'testproject config_file':
    ensure  => 'file',
    path    => '/tmp/testproject.json',
    content => template($config_source)
  }
}
