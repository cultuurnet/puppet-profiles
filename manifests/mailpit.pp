class profiles::mailpit (
  Stdlib::IP::Address::V4 $smtp_address = '127.0.0.1',
  Integer                 $smtp_port    = 1025,
  Stdlib::IP::Address::V4 $http_address = '127.0.0.1',
  Integer                 $http_port    = 8025,

) inherits ::profiles {

  realize Group['mailpit']
  realize User['mailpit']
  realize Apt::Source['publiq-tools']

  package { 'mailpit':
    ensure  => 'installed',
    require => Apt::Source['publiq-tools']
  }

  file { 'mailpit-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/mailpit',
    content => "SMTP_ADDRESS=${smtp_address}\nSMTP_PORT=${smtp_port}\nHTTP_ADDRESS=${http_address}\nHTTP_PORT=${http_port}",
    notify  => Service['mailpit']
  }

  service { 'mailpit':
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    require   => [Group['mailpit'], User['mailpit']]
  }
}
