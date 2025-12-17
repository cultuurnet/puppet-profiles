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
    content => $balies_config_source,
    require => File[$basedir]
  }

  exec { 'create elasticsearch balies mapping':
    command     => "/usr/bin/curl -XPUT 'localhost:9200/balies?pretty' -H 'Content-Type: application/json' -d @${basedir}/mapping_balies.json",
    logoutput   => true,
    refreshonly => true,
    subscribe   => File['uitpas-elasticsearch-balies-mapping'],
    unless      => '/usr/bin/curl -s localhost:9200/balies/_mappings | /usr/bin/jq -e .balies'
  }

  exec { 'update elasticsearch balies mapping':
    command     => "/usr/bin/curl -XPATCH 'localhost:9200/balies?pretty' -H 'Content-Type: application/json' -d @${basedir}/mapping_balies.json",
    logoutput   => true,
    refreshonly => true,
    subscribe   => File['uitpas-elasticsearch-balies-mapping'],
    onlyif      => '/usr/bin/curl -s localhost:9200/balies/_mappings | /usr/bin/jq -e .balies'
  }

  file { 'uitpas-elasticsearch-promotions-mapping':
    ensure  => 'file',
    path    => "${basedir}/mapping_promotions.json",
    content => $promotions_config_source,
    require => File[$basedir]
  }

  exec { 'create elasticsearch promotions mapping':
    command     => "/usr/bin/curl -XPUT 'localhost:9200/promotions?pretty' -H 'Content-Type: application/json' -d @${basedir}/mapping_promotions.json",
    logoutput   => true,
    refreshonly => true,
    subscribe   => File['uitpas-elasticsearch-promotions-mapping'],
    unless      => '/usr/bin/curl -s localhost:9200/promotions/_mappings | /usr/bin/jq -e .promotions'
  }

  exec { 'update elasticsearch promotions mapping':
    command     => "/usr/bin/curl -XPATCH 'localhost:9200/promotions?pretty' -H 'Content-Type: application/json' -d @${basedir}/mapping_promotions.json",
    logoutput   => true,
    refreshonly => true,
    subscribe   => File['uitpas-elasticsearch-promotions-mapping'],
    onlyif      => '/usr/bin/curl -s localhost:9200/promotions/_mappings | /usr/bin/jq -e .promotions'
  }
}
