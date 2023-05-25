class profiles::puppet::puppetserver (
  String                                   $version           = 'installed',
  Optional[Variant[String, Array[String]]] $dns_alt_names     = undef,
  Boolean                                  $autosign          = false,
  Variant[String, Array[String]]           $trusted_amis      = [],
  Optional[String]                         $initial_heap_size = undef,
  Optional[String]                         $maximum_heap_size = undef,
  Boolean                                  $service_enable    = true,
  String                                   $service_ensure    = 'running'

) inherits ::profiles {

  $default_ini_setting_attributes = {
                                      path    => '/etc/puppetlabs/puppet/puppet.conf',
                                      section => 'server'
                                    }

  include profiles::firewall::rules

  realize Group['puppet']
  realize User['puppet']
  realize Apt::Source['puppet']

  realize Firewall['300 accept puppetserver HTTPS traffic']

  contain profiles::java

  ini_setting { 'puppetserver ca_server':
    ensure  => 'present',
    setting => 'ca_server',
    value   => $facts['fqdn'],
    before  => Package['puppetserver'],
    notify  => Service['puppetserver'],
    *       => $default_ini_setting_attributes
  }

  if $dns_alt_names {
    ini_setting { 'puppetserver dns_alt_names':
      ensure  => 'present',
      setting => 'dns_alt_names',
      value   => [$dns_alt_names].flatten.join(','),
      before  => Package['puppetserver'],
      *       => $default_ini_setting_attributes
    }
  } else {
    ini_setting { 'puppetserver dns_alt_names':
      ensure  => 'absent',
      setting => 'dns_alt_names',
      before  => Package['puppetserver'],
      *       => $default_ini_setting_attributes
    }
  }

  if $autosign {
    class { 'profiles::puppet::puppetserver::autosign':
      trusted_amis => $trusted_amis,
      notify       => Service['puppetserver']
    }

    ini_setting { 'puppetserver autosign':
      ensure  => 'present',
      setting => 'autosign',
      value   => '/etc/puppetlabs/puppet/autosign',
      notify  => Service['puppetserver'],
      *       => $default_ini_setting_attributes
    }
  } else {
    ini_setting { 'puppetserver autosign':
      ensure  => 'absent',
      setting => 'autosign',
      *       => $default_ini_setting_attributes
    }
  }

  package { 'puppetserver':
    ensure  => $version,
    require => [Group['puppet'], User['puppet'], Apt::Source['puppet'], Class['profiles::java']],
    notify  => Service['puppetserver']
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
    hasstatus => true
  }
}
