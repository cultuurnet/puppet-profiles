class profiles::uit::mail_subscriptions::deployment (
  String           $config_source,
  String           $version                 = 'latest',
  Boolean          $service_manage          = true,
  String           $service_ensure          = 'running',
  Boolean          $service_enable          = true,
  Optional[String] $service_defaults_source = undef,
  Optional[String] $puppetdb_url            = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uit-mail-subscriptions'

  realize Apt::Source['uit-mail-subscriptions']

  package { 'uit-mail-subscriptions':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['uit-mail-subscriptions']
  }

  file { 'uit-mail-subscriptions-config':
    ensure  => 'file',
    path    => "${basedir}/packages/rabbitmq/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uit-mail-subscriptions']
  }

  if $service_manage {
    if $service_defaults_source {
      file { 'uit-mail-subscriptions-service-defaults':
        ensure => 'file',
        path   => '/etc/default/uit-mail-subscriptions',
        owner  => 'root',
        group  => 'root',
        source => $service_defaults_source,
        notify => Service['uit-mail-subscriptions']
      }
    }

    service { 'uit-mail-subscriptions':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uit-mail-subscriptions'],
      subscribe => File['uit-mail-subscriptions-config'],
      hasstatus => true
    }
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
