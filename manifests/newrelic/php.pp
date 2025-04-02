class profiles::newrelic::php (
  String           $app_name    = $facts['networking']['fqdn'],
  Optional[String] $license_key = lookup('data::newrelic::license_key', Optional[String], 'first', undef)
) inherits ::profiles {

  unless $license_key {
    fail("Class[Profiles::Newrelic::Php] expects a value for parameter 'license_key'")
  }

  realize Apt::Source['newrelic']

  file { 'newrelic-php5-installer.preseed':
    path    => '/var/tmp/newrelic-php5-installer.preseed',
    content => template('profiles/newrelic/newrelic-php5-installer.preseed.erb'),
    mode    => '0600',
    backup  => false
  }

  package { 'newrelic-php5':
    ensure       => 'latest',
    responsefile => '/var/tmp/newrelic-php5-installer.preseed',
    require      => [File['newrelic-php5-installer.preseed'], Apt::Source['newrelic']]
  }
}
