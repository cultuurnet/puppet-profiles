class profiles::puppet::puppetserver (
  String                                   $version           = 'latest',
  Optional[Variant[String, Array[String]]] $dns_alt_names     = undef,
  Optional[String]                         $initial_heap_size = undef,
  Optional[String]                         $maximum_heap_size = undef,
  Boolean                                  $service_enable    = true,
  String                                   $service_ensure    = 'running'

) inherits ::profiles {

  include profiles::firewall::rules

  realize Group['puppet']
  realize User['puppet']
  realize Apt::Source['puppet']

  realize Firewall['300 accept puppetserver HTTPS traffic']

  contain profiles::java

  ini_setting { 'puppetserver ca_server':
    ensure  => 'present',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'server',
    setting => 'ca_server',
    value   => $facts['fqdn'],
    before  => Package['puppetserver'],
    notify  => Service['puppetserver']
  }

  if $dns_alt_names {
    ini_setting { 'puppetserver dns_alt_names':
      ensure  => 'present',
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      section => 'server',
      setting => 'dns_alt_names',
      value   => [$dns_alt_names].flatten.join(','),
      before  => Package['puppetserver']
    }
  } else {
    ini_setting { 'puppetserver dns_alt_names':
      ensure  => 'absent',
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      section => 'server',
      setting => 'dns_alt_names',
      before  => Package['puppetserver']
    }
  }

  package { 'puppetserver':
    ensure  => $version,
    require => [Group['puppet'], User['puppet'], Apt::Source['puppet'], Class['profiles::java']]
  }

  if $initial_heap_size {
    augeas { 'puppetserver_initial_heap_size':
      lens    => 'Shellvars_list.lns',
      incl    => '/etc/default/puppetserver',
      context => '/files/etc/default/puppetserver/JAVA_ARGS',
      changes => "set value[. =~ regexp('-Xms.*')] '-Xms${initial_heap_size}'",
      notify  => Service['puppetserver']
    }
  }

  if $maximum_heap_size {
    augeas { 'puppetserver_maximum_heap_size':
      lens    => 'Shellvars_list.lns',
      incl    => '/etc/default/puppetserver',
      context => '/files/etc/default/puppetserver/JAVA_ARGS',
      changes => "set value[. =~ regexp('-Xmx.*')] '-Xmx${maximum_heap_size}'",
      notify  => Service['puppetserver']
    }
  }

  service { 'puppetserver':
    ensure    => $service_ensure,
    enable    => $service_enable,
    hasstatus => true,
    subscribe => Package['puppetserver']
  }
}
