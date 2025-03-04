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

  systemd::dropin_file { 'newrelic-infra_override.conf':
    ensure   => 'present',
    unit     => 'newrelic-infra.service',
    filename => 'override.conf',
    content  => "[Service]\nPIDFile=/run/newrelic-infra/newrelic-infra.pid"
  }

  file { '/etc/newrelic-infra/integrations.d':
    ensure  => 'directory',
    recurse => true,
    purge   => true
  }

  file { '/etc/newrelic-infra/logging.d':
    ensure  => 'directory',
    recurse => true,
    purge   => true
  }
}
