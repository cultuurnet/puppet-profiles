class profiles::uit::mail_subscriptions::deployment (
  String                     $config_source,
  String                     $version        = 'latest',
  String                     $repository     = 'uit-mail-subscriptions',
  Enum['running', 'stopped'] $service_status = 'running',
  Optional[String]           $puppetdb_url   = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uit-mail-subscriptions'
  $secrets = lookup('vault:uit/mail-subscriptions')

  realize Apt::Source[$repository]

  package { 'uit-mail-subscriptions':
    ensure  => $version,
    notify  => [Service['uit-mail-subscriptions'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'uit-mail-subscriptions-config':
    ensure  => 'file',
    path    => "${basedir}/packages/rabbitmq/.env",
    owner   => 'www-data',
    group   => 'www-data',
    content  => template($config_source),
    require => Package['uit-mail-subscriptions'],
    notify  => Service['uit-mail-subscriptions']
  }

  file { 'uit-mail-subscriptions-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uit-mail-subscriptions',
    owner   => 'root',
    group   => 'root',
    content => 'NODE_ENV=production',
    notify  => Service['uit-mail-subscriptions']
  }

  service { 'uit-mail-subscriptions':
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
