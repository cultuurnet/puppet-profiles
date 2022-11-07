class profiles::elasticdump inherits ::profiles {

  include ::profiles::nodejs

  realize Apt::Source['publiq-tools']

  package { 'elasticdump':
    require => [Apt::Source['publiq-tools'], Class['profiles::nodejs']]
  }

  alternative_entry { '/opt/elasticdump/node_modules/elasticdump/bin/elasticdump':
    ensure   => 'present',
    altname  => 'elasticdump',
    priority => 10,
    altlink  => '/usr/bin/elasticdump',
    require  => Package['elasticdump']
  }
}
