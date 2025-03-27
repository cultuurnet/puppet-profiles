class profiles::testproject::testcomponent (
  String $config_source,
) inherits ::profiles {

  $secrets = lookup('vault:testproject/testcomponent')

  file { 'testproject config_file':
    ensure  => 'file',
    path    => '/tmp/testproject.json',
    content => template($config_source)
  }

  include profiles::php

  class { 'profiles::newrelic::php':
    app_name    => 'testproject',
    license_key => 'eu01xx3dc2cab413942d94ef142a73e4FFFFNRAL' # <= temp, will be deleted
  }

  file { 'testproject_1_webdir':
    ensure  => 'directory',
    path    => '/var/www/testproject_1',
    require => Class['apache']
  }

  file { 'testproject_2_webdir':
    ensure  => 'directory',
    path    => '/var/www/testproject_2',
    require => Class['apache']
  }

  profiles::apache::vhost::php_fpm { 'testproject_1':
    basedir              => '/var/www/',
    public_web_directory => 'testproject_1',
    require              => File['testproject_1_webdir']
  }

  profiles::apache::vhost::php_fpm { 'testproject_2':
    basedir              => '/var/www/',
    public_web_directory => 'testproject_2',
    require              => File['testproject_2_webdir']
  }
}
