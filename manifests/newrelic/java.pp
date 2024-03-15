class profiles::newrelic::java (
  String $ensure = 'installed'
) inherits ::profiles {

  realize Apt::Source['publiq-tools']

  package { 'newrelic-java':
    ensure  => $ensure,
    require => Apt::Source['publiq-tools']
  }
}
