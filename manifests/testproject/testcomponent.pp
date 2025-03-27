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
  include profiles::newrelic::php

  class profiles::apache::vhost::php_fpm { 'testproject':
    'basedir'              => '/var/www/',
    'public_web_directory' => 'html'
  }
}
