class profiles::newrelic::infrastructure (
  Optional[String]                        $license_key    = lookup('data::newrelic::license_key', Optional[String], 'first', undef),
  Optional[String]                        $version        = 'latest',
  Enum['running', 'stopped']              $service_status = 'running',
  Enum['debug', 'info', 'smart', 'trace'] $log_level      = 'info',
  Hash                                    $attributes     = {}
) inherits ::profiles {

  if $license_key {
    class { 'profiles::newrelic::infrastructure::install':
      version => $version,
      notify  => Class['profiles::newrelic::infrastructure::service']
    }

    class { 'profiles::newrelic::infrastructure::configuration':
      license_key => $license_key,
      log_level   => $log_level,
      attributes  => $attributes,
      require     => Class['profiles::newrelic::infrastructure::install'],
      notify      => Class['profiles::newrelic::infrastructure::service']
    }

    class { 'profiles::newrelic::infrastructure::service':
      status => $service_status
    }
  }
}

