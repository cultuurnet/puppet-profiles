class profiles::deployment::uit::mail_subscriptions (
  String           $config_source,
  String           $version                 = 'latest',
  Boolean          $service_manage          = true,
  String           $service_ensure          = 'running',
  Boolean          $service_enable          = true,
  Optional[String] $service_defaults_source = undef,
  Optional[String] $puppetdb_url            = undef
) inherits ::profiles {

  $basedir = '/var/www/uit-mail-subscriptions'

  realize Apt::Source['publiq-uit']

  package { 'uit-mail-subscriptions':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['publiq-uit']
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
    project      => 'uit',
    packages     => 'uit-mail-subscriptions',
    puppetdb_url => $puppetdb_url
  }
}
