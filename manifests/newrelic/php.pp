class profiles::newrelic::php (
  String $app_name,
  String $license_key
) inherits ::profiles {

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
    require      => File['newrelic-php5-installer.preseed']
  }
}
