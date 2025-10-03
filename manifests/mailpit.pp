class profiles::mailpit (
  Stdlib::IP::Address::V4 $smtp_address = '127.0.0.1',
  Stdlib::IP::Address::V4 $http_address = '127.0.0.1'

) inherits ::profiles {

  $smtp_port = 1025
  $http_port = 8025

  include profiles::firewall::rules

  realize Group['mailpit']
  realize User['mailpit']
  realize Apt::Source['publiq-tools']

  if !($smtp_address == '127.0.0.1') {
    realize Firewall['400 accept mailpit SMTP traffic']
  }

  package { 'mailpit':
    ensure  => 'installed',
    require => Apt::Source['publiq-tools']
  }

  file { 'mailpit-datadir':
    ensure  => 'directory',
    path    => '/var/lib/mailpit',
    owner   => 'mailpit',
    group   => 'mailpit',
    require => [Group['mailpit'], User['mailpit']]
  }

  file { 'mailpit-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/mailpit',
    content => "SMTP_ADDRESS=${smtp_address}\nSMTP_PORT=${smtp_port}\nHTTP_ADDRESS=${http_address}\nHTTP_PORT=${http_port}\nENVIRONMENT=${environment}",
    notify  => Service['mailpit']
  }

  service { 'mailpit':
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    require   => [Group['mailpit'], User['mailpit'], File['mailpit-datadir']]
  }
}
