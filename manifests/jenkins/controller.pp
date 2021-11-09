class profiles::jenkins::controller (
  Stdlib::Httpurl $url,
  String          $certificate,
  String          $version     = 'latest'
) inherits ::profiles {

  include ::profiles::groups
  include ::profiles::users
  include ::profiles::java
  include ::profiles::jenkins::repositories

  $transport  = split($url, ':')[0]
  $hostname   = split($url, '/')[2]
  $config_dir = '/var/lib/jenkins/casc_config'

  realize Group['jenkins']
  realize User['jenkins']

  realize Profiles::Apt::Update['publiq-jenkins']

  package { 'jenkins':
    ensure  => $version,
    require => [ User['jenkins'], Class['profiles::java'], Profiles::Apt::Update['publiq-jenkins']],
    notify  => Class['profiles::jenkins::controller::service']
  }

  class { '::profiles::jenkins::controller::service': }

  file { 'casc_config':
    ensure  => 'directory',
    path    => $config_dir,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => Package['jenkins'],
    notify  => Class['profiles::jenkins::controller::service']
  }

  shellvar { 'JAVA_ARGS':
    ensure   => 'present',
    variable => 'JAVA_ARGS',
    target   => '/etc/default/jenkins',
    value    => "-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=${config_dir}",
    require  => File['casc_config'],
    notify   => Class['profiles::jenkins::controller::service']
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
