class profiles::newrelic-php5 (
  String $package_name = 'newrelic-php5'
) inherits ::profiles {

  realize Apt::Source["newrelic"]
  realize Package[$package_name]

  # do something with debconf-set-selections to set appname and license key
  # see: https://docs.newrelic.com/docs/apm/agents/php-agent/installation/php-agent-installation-ubuntu-debian/
  #
  exec { 'update_newrelic_app_name':
    command     => "echo ${package_name} ${package_name}/application-name string \"${newrelic_app_name} \" | debconf-set-selections",
    path        => ['/usr/bin'],
    onlyif      => "test 0 -eq $(debconf-show ${package_name} | grep ${package_name/application-name | wc -l)",
    refreshonly => true,
  }
  exec { 'update_newrelic_license_key':
    command     => "echo ${package_name} ${package_name}/license-key string \"${newrelic_license_key} \" | debconf-set-selections",
    path        => ['/usr/bin'],
    onlyif      => "test 0 -eq $(debconf-show ${package_name} | grep ${package_name/license-key | wc -l)",
    refreshonly => true
  }
}
