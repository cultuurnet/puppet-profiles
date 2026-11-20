define profiles::newrelic::php::application (
  String           $docroot,
  Boolean          $enable                                 = false,
  Optional[String] $app_name                               = undef,
  Optional[Hash]   $optional_config                        = {},
  Boolean          $application_logging_forwarding_enabled = false,
  Boolean          $transaction_tracer_enabled             = false,
  Boolean          $distributed_tracing_enabled            = false
) {

  include ::profiles

  if $enable {
    # Normalize the logical resource title for the default New Relic app name.
    $default_app_name = regsubst("${title}-${environment}", '_', '-', 'G')
    $appname          = $app_name ? {
      undef   => $default_app_name,
      default => $app_name
    }
    $file_content     = template('profiles/newrelic/php/user.ini.erb')

    include ::profiles::newrelic::php
    $requirements = [Group['www-data'], User['www-data'], Class['profiles::newrelic::php']]
  } else {
    $file_content = undef
    $requirements = [Group['www-data'], User['www-data']]
  }

  file { "${title} newrelic php config":
    ensure  => $enable ? {
                 true  => 'file',
                 false => 'absent'
               },
    path    => "${docroot}/.user.ini",
    owner   => 'www-data',
    group   => 'www-data',
    content => $file_content,
    require => $requirements
  }

}
