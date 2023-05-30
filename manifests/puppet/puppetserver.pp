class profiles::puppet::puppetserver (
  String                                   $version           = 'installed',
  Optional[Variant[String, Array[String]]] $dns_alt_names     = undef,
  Boolean                                  $autosign          = false,
  Variant[String, Array[String]]           $trusted_amis      = [],
  Variant[String, Array[String]]           $trusted_certnames = [],
  Optional[String]                         $puppetdb_url      = undef,
  Optional[String]                         $initial_heap_size = undef,
  Optional[String]                         $maximum_heap_size = undef,
  Enum['running', 'stopped']               $service_status    = 'running'

) inherits ::profiles {

  if ($autosign and !empty($trusted_amis) and !empty($trusted_certnames)) {
    fail("Class Profiles::Puppet::Puppetserver expects either a value for parameter 'trusted_amis' or 'trusted_certnames' when autosigning")
  }

  $default_ini_setting_attributes = {
                                      path    => '/etc/puppetlabs/puppet/puppet.conf',
                                      section => 'server'
                                    }

  include profiles::firewall::rules

  realize Group['puppet']
  realize User['puppet']
  realize Apt::Source['puppet']

  realize Firewall['300 accept puppetserver HTTPS traffic']

  include profiles::java

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

  class { 'profiles::puppet::puppetserver::autosign':
    autosign          => $autosign,
    trusted_amis      => $trusted_amis,
    trusted_certnames => $trusted_certnames,
    notify            => Service['puppetserver']
  }

  class { 'profiles::puppet::puppetserver::puppetdb':
    url    => $puppetdb_url,
    notify => Service['puppetserver']
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

  $service_enable = $service_status ? {
    'running' => true,
    'stopped' => false
  }

  service { 'puppetserver':
    ensure    => $service_status,
    enable    => $service_enable,
    hasstatus => true
  }
}
