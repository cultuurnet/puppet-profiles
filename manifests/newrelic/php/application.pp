define profiles::newrelic::php::application (
  Boolean        $enable                                 = false,
  String         $docroot,
  Optional[Hash] $optional_config                        = {},
  Boolean        $application_logging_forwarding_enabled = false,
  Boolean        $transaction_tracer_enabled             = false,
  Boolean        $distributed_tracing_enabled            = false
) {

  include ::profiles
  include ::profiles::newrelic::php

  $appname = "${title}_${environment}"

  file { "${appname} newrelic php config":
    ensure  => $enable ? {
                 true  => 'file',
                 false => 'absent'
               },
    path    => "${docroot}/.user.ini",
    owner   => 'www-data',
    group   => 'www-data',
    content => template('profiles/newrelic/php/user.ini.erb'),
    require => [Group['www-data'], User['www-data']]
  }

}
