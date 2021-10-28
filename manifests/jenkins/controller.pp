class profiles::jenkins::controller (
  String $hostname,
  String $certificate,
  String $version     = 'latest'
) inherits ::profiles {

  include ::profiles::groups
  include ::profiles::users
  include ::profiles::java
  include ::profiles::jenkins::repositories

  realize Group['jenkins']
  realize User['jenkins']

  realize Profiles::Apt::Update['publiq-jenkins']

  package { 'jenkins':
    ensure  => $version,
    require => [ User['jenkins'], Class['profiles::java'], Profiles::Apt::Update['publiq-jenkins']]
  }

  file { 'casc_config':
    ensure  => 'directory',
    path    => '/var/lib/jenkins/casc_config',
    owner   => 'jenkins',
    group   => 'jenkins',
    require => Package['jenkins'],
    notify  => Service['jenkins']
  }

  service { 'jenkins':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
    require   => Package['jenkins']
  }

  profiles::apache::vhost::redirect { "http://${hostname}":
    destination => "https://${hostname}"
  }

  profiles::apache::vhost::reverse_proxy { "https://${hostname}":
    destination           => 'http://127.0.0.1:8080/',
    certificate           => $certificate,
    preserve_host         => true,
    allow_encoded_slashes => 'nodecode',
    proxy_keywords        => 'nocanon',
    support_websockets    => true
  }
}
