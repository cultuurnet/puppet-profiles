define profiles::newrelic::infrastructure::logging (
  Variant[String, Hash]                    $source,
  Enum['file', 'systemd', 'syslog', 'tcp'] $source_type = 'file',
  Hash                                     $attributes  = {},
  Optional[String]                         $pattern     = undef
) {

  include ::profiles
  include ::profiles::newrelic::infrastructure

  $config_dir  = '/etc/newrelic-infra/logging.d'

  file { "newrelic-infrastructure-${title}":
    ensure  => file,
    path    => "${config_dir}/${title}.yml",
    content => template('profiles/newrelic/infrastructure/logging-config.yml.erb'),
    require => Class['profiles::newrelic::infrastructure::install'],
    notify  => Class['profiles::newrelic::infrastructure::service']
  }
}
