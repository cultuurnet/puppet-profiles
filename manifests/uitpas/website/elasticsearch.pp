class profiles::uitpas::website::elasticsearch (
  String $balies_config_source,
  String $promotions_config_source
) inherits ::profiles {

  include ::profiles::elasticsearch

  $basedir = '/opt/elasticsearch-uitpas-mappings'

  file { $basedir:
    ensure  => 'directory',
  }

  file { 'uitpas-elasticsearch-balies-mapping':
    ensure  => 'file',
    path    => "${basedir}/mapping_balies.json",
    source  => $balies_config_source,
    require => File[$basedir]
  }

  exec { 'elasticsearch balies mapping':
    command     => "/usr/bin/curl -XPUT 'localhost:9200/balies?pretty -H 'Content-Type: application/json' -d @${basedir}/mapping_balies.json",
    logoutput   => true,
    refreshonly => true,
    subscribe   => File['uitpas-elasticsearch-balies-mapping'],
    require     => File['uitpas-elasticsearch-balies-mapping']
  }

  file { 'uitpas-elasticsearch-promotions-mapping':
    ensure  => 'file',
    path    => "${basedir}/mapping_promotions.json",
    source  => $promotions_config_source,
    require => File[$basedir]
  }

  exec { 'elasticsearch promotions mapping':
    command     => "/usr/bin/curl -XPUT 'localhost:9200/promotions?pretty -H 'Content-Type: application/json' -d @${basedir}/mapping_promotions.json",
    logoutput   => true,
    refreshonly => true,
    subscribe   => File['uitpas-elasticsearch-promotions-mapping'],
    require     => File['uitpas-elasticsearch-promotions-mapping']
  }
}
