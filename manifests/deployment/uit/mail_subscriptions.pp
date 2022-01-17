class profiles::deployment::uit::mail_subscriptions (
  String           $config_source,
  String           $version                 = 'latest',
  Boolean          $service_manage          = true,
  String           $service_ensure          = 'running',
  Boolean          $service_enable          = true,
  Optional[String] $service_defaults_source = undef,
  Optional[String] $puppetdb_url            = undef
) inherits ::profiles {

  include ::profiles::apt::updates
  include ::profiles::deployment::uit

  $basedir = '/var/www/uit-mail-subscriptions'

  realize Profiles::Apt::Update['publiq-uit']

  package { 'uit-mail-subscriptions':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uit']
  }

  file { 'uit-mail-subscriptions-config':
    ensure  => 'file',
    path    => "${basedir}/packages/rabbitmq/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uit-mail-subscriptions']
  }

  file { 'uit-mail-subscriptions-log':
    ensure => 'directory',
    path   => '/var/log/uit-mail-subscriptions',
    owner  => 'www-data',
    group  => 'www-data'
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
      require   => [ Package['uit-mail-subscriptions'], File['uit-mail-subscriptions-log']],
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
