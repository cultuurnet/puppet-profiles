class profiles::uit::recommender_frontend::deployment (
  String                     $config_source,
  String                     $version        = 'latest',
  String                     $repository     = 'uit-recommender-frontend',
  Enum['running', 'stopped'] $service_status = 'running',
  Integer                    $service_port   = 6000,
  Optional[String]           $puppetdb_url   = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uit-recommender-frontend'
  $secrets = lookup('vault:uit/recommender-frontend')

  realize Group['www-data']
  realize User['www-data']
  realize Apt::Source[$repository]

  package { 'uit-recommender-frontend':
    ensure  => $version,
    notify  => [Service['uit-recommender-frontend'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'uit-recommender-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    content  => template($config_source),
    require => [Group['www-data'], User['www-data'], Package['uit-recommender-frontend']],
    notify  => Service['uit-recommender-frontend']
  }

  file { 'uit-recommender-frontend-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uit-recommender-frontend',
    owner   => 'root',
    group   => 'root',
    content => "PORT=${service_port}",
    require => Package['uit-recommender-frontend'],
    notify  => Service['uit-recommender-frontend']
  }

  service { 'uit-recommender-frontend':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 }
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
