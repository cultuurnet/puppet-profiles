class profiles::newrelic::infrastructure::install (
  Optional[String] $version = 'latest'
) inherits ::profiles {

  realize Apt::Source['newrelic-infra']

  package { 'newrelic-infra':
    ensure => $version
  }
}
