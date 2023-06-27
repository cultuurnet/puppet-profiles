class profiles::logstash (
  String                     $version         = 'installed',
  String                     $input_source    = undef,
  String                     $filter_source   = undef,
  String                     $output_source   = undef,
  Hash                       $plugins         = {},
  Optional[Variant[Hash]]    $config_defaults = undef,
  Enum['running', 'stopped'] $service_status  = 'running'
) inherits ::profiles {

  include profiles::java

  realize Group['logstash']
  realize User['logstash']

  realize Apt::Source['elastic-8.x']

  package { 'logstash':
    ensure  => $version,
    require => [User['logstash'],Class['profiles::java'],Apt::Source['elastic-8.x']],
    notify  => Service['logstash']
  }

  $plugins.each |$plugin,$properties| {
    profiles::logstash::plugin { $plugin:
      * => $properties
    }
  }

  file { 'logstash_config_defaults':
    ensure => 'file',
    path    => '/etc/default/logstash',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('profiles/logstash/config_defaults.erb'),
    require => [Package['logstash']],
    notify  => Service['logstash']
  }

  file { 'logstash_input':
    ensure  => 'file',
    path    => '/etc/logstash/conf.d/input.conf',
    owner   => 'logstash',
    group   => 'logstash',
    mode    => '0640',
    source  => $input_source,
    require => [Package['logstash']],
    notify  => Service['logstash']
  }

  file { 'logstash_filter':
    ensure  => 'file',
    path    => '/etc/logstash/conf.d/filter.conf',
    owner   => 'logstash',
    group   => 'logstash',
    mode    => '0640',
    source  => $filter_source,
    require => [Package['logstash']],
    notify  => Service['logstash']
  }

  file { 'logstash_output':
    ensure  => 'file',
    path    => '/etc/logstash/conf.d/output.conf',
    owner   => 'logstash',
    group   => 'logstash',
    mode    => '0640',
    source  => $output_source,
    require => [Package['logstash']],
    notify  => Service['logstash']
  }

  service { 'logstash':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 }
  }
}

