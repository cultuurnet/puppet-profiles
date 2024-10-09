class profiles::newrelic::infrastructure::configuration (
  String                                  $license_key,
  Enum['debug', 'info', 'smart', 'trace'] $log_level   = 'info',
  Hash                                    $attributes  = {}
) inherits ::profiles {

  $log_size_mb        = 100
  $log_max_files      = 10
  $default_attributes = { 'environment' => $environment }

  $custom_attributes = $default_attributes + $attributes

  file { '/etc/newrelic-infra.yml':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('profiles/newrelic/infrastructure/newrelic-infra.yml.erb')
  }
}
