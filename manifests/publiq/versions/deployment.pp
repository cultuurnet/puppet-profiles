class profiles::publiq::versions::deployment (
  String                     $version                 = 'latest',
  Boolean                    $service_manage          = true,
  String                     $service_ensure          = 'running',
  Boolean                    $service_enable          = true,
  Stdlib::Ipv4               $service_address         = '127.0.0.1',
  Stdlib::Port::Unprivileged $service_port            = 3000,
  Optional[String]           $puppetdb_url            = undef
) inherits ::profiles {

  realize Apt::Source['publiq-versions']

  package { 'publiq-versions':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['publiq-versions']
  }

  if $service_manage {
    file { 'publiq-versions-service-defaults':
      ensure  => 'file',
      path    => '/etc/default/publiq-versions',
      owner   => 'root',
      group   => 'root',
      content => template('profiles/publiq/versions/deployment.erb'),
      notify  => Service['publiq-versions']
    }

    service { 'publiq-versions':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['publiq-versions'],
      hasstatus => true
    }
  }

  profiles::deployment::versions { $title:
    project      => 'publiq',
    packages     => 'publiq-versions',
    puppetdb_url => $puppetdb_url
  }
}
