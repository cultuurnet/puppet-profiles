class profiles::newrelic::infrastructure (
  Optional[String]                        $license_key    = lookup('data::newrelic::license_key', Optional[String], 'first', undef),
  Optional[String]                        $version        = 'latest',
  Enum['running', 'stopped']              $service_status = 'running',
  Enum['debug', 'info', 'smart', 'trace'] $loglevel       = 'info',
  Hash                                    $attributes     = {}
) inherits ::profiles {

  if $license_key {
    class { 'profiles::newrelic::infrastructure::install':
      version => $version
    }

    class { 'profiles::newrelic::infrastructure::configuration':
      license_key => $license_key,
      loglevel    => $loglevel,
      attributes  => $attributes
    }

    class { 'profiles::newrelic::infrastructure::service':
      status => $service_status
    }

    Class['profiles::newrelic::infrastructure::install'] -> Class['profiles::newrelic::infrastructure::configuration']
    Class['profiles::newrelic::infrastructure::configuration'] ~> Class['profiles::newrelic::infrastructure::service']

  } else {
    fail("Class Profiles::Newrelic::Infrastructure expects a value for parameter 'license_key'")
  }
}

