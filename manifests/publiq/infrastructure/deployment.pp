class profiles::publiq::infrastructure::deployment (
  String $version    = 'latest',
  String $repository = 'publiq-infrastructure'
) inherits ::profiles {

  include ::profiles::puppet::puppetserver::cache_clear

  realize Apt::Source[$repository]

  package { 'publiq-infrastructure':
    ensure  => $version,
    notify  => Class['profiles::puppet::puppetserver::cache_clear'],
    require => Apt::Source[$repository]
  }

  file { 'publiq-infrastructure get_config_version':
    ensure  => 'file',
    path    => '/etc/puppetlabs/code/get_config_version.sh',
    mode    => '0755',
    content => "#!/bin/sh\n\n/usr/bin/dpkg-query -f='\${Version}\\n' -W publiq-infrastructure",
    require => Package['publiq-infrastructure'],
    notify  => Class['profiles::puppet::puppetserver::cache_clear']
  }

  ['acceptance', 'testing', 'production'].each |$env| {
    file { "publiq-infrastructure ${env} environment environment.conf":
      ensure  => 'file',
      path    => "/etc/puppetlabs/code/environments/${env}/environment.conf",
      content => 'config_version = /etc/puppetlabs/code/get_config_version.sh',
      require => [ Package['publiq-infrastructure'], File['publiq-infrastructure get_config_version']],
      notify  => Class['profiles::puppet::puppetserver::cache_clear']
    }
  }
}
