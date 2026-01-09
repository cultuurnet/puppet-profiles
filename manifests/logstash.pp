class profiles::logstash (
  String                     $version         = 'installed',
  String                     $input_source    = undef,
  String                     $filter_source   = undef,
  String                     $output_source   = undef,
  Hash                       $plugins         = {},
  Optional[Variant[Hash]]    $config_defaults = undef,
  Enum['running', 'stopped'] $service_status  = 'running'
) inherits ::profiles {

  $file_default_attributes = {
                               ensure  => 'file',
                               owner   => 'logstash',
                               group   => 'logstash',
                               mode    => '0640',
                               require => Package['logstash'],
                               notify  => Service['logstash']
                             }

  include profiles::java
  include profiles::firewall::rules
  include profiles::data_integration

  realize Group['logstash']
  realize User['logstash']

  realize Apt::Source['elastic-8.x']
  realize Firewall['400 accept logstash filebeat traffic']

  package { 'logstash':
    ensure  => $version,
    require => [Group['logstash'], User['logstash'], Class['profiles::java'], Apt::Source['elastic-8.x']],
    notify  => Service['logstash']
  }

  $plugins.each |$plugin, $properties| {
    profiles::logstash::plugin { $plugin:
      notify  => Service['logstash'],
      *       => $properties
    }
  }

  file { 'logstash_config_defaults':
    ensure  => 'file',
    path    => '/etc/default/logstash',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('profiles/logstash/config_defaults.erb'),
    require => Package['logstash'],
    notify  => Service['logstash']
  }

  file { 'logstash_input':
    path   => '/etc/logstash/conf.d/input.conf',
    source => $input_source,
    *      => $file_default_attributes
  }

  file { 'logstash_filter':
    path   => '/etc/logstash/conf.d/filter.conf',
    source => $filter_source,
    *      => $file_default_attributes
  }

  file { 'logstash_output':
    path   => '/etc/logstash/conf.d/output.conf',
    source => $output_source,
    *      => $file_default_attributes
  }

  service { 'logstash':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 }
  }

  cron { 'remove-old-logstash-logs':
    command     => "/usr/bin/find /var/log/logstash -type f -mtime +10 -name '*.log.gz' -delete",
    environment => ['MAILTO=infra+cron@publiq.be'],
    user        => 'root',
    hour        => '2',
    minute      => '0'
  }
}
