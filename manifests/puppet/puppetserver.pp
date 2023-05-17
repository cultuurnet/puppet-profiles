class profiles::puppet::puppetserver (
  String           $version           = 'latest',
  Optional[String] $initial_heap_size = undef,
  Optional[String] $maximum_heap_size = undef,
  Boolean          $service_manage    = true,
  Boolean          $service_enable    = true,
  String           $service_ensure    = 'running'

) inherits ::profiles {

  include profiles::firewall::rules

  realize Group['puppet']
  realize User['puppet']
  realize Apt::Source['puppet']

  realize Firewall['300 accept puppetserver HTTPS traffic']

  contain profiles::java

  package { 'puppetserver':
    ensure  => $version,
    require => [Group['puppet'], User['puppet'], Apt::Source['puppet'], Class['profiles::java']]
  }

  if $initial_heap_size {
    augeas { 'puppetserver_initial_heap_size':
      lens    => 'Shellvars_list.lns',
      incl    => '/etc/default/puppetserver',
      context => '/files/etc/default/puppetserver/JAVA_ARGS',
      changes => "set value[. =~ regexp('-Xms.*')] '-Xms${initial_heap_size}'"
    }

    if $service_manage {
      Augeas['puppetserver_initial_heap_size'] ~> Service['puppetserver']
    }
  }

  if $maximum_heap_size {
    augeas { 'puppetserver_maximum_heap_size':
      lens    => 'Shellvars_list.lns',
      incl    => '/etc/default/puppetserver',
      context => '/files/etc/default/puppetserver/JAVA_ARGS',
      changes => "set value[. =~ regexp('-Xmx.*')] '-Xmx${maximum_heap_size}'"
    }

    if $service_manage {
      Augeas['puppetserver_maximum_heap_size'] ~> Service['puppetserver']
    }
  }

  if $service_manage {
    service { 'puppetserver':
      ensure    => $service_ensure,
      enable    => $service_enable,
      hasstatus => true,
      subscribe => Package['puppetserver']
    }
  }
}
