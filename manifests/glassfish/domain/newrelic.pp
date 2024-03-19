define profiles::glassfish::domain::newrelic (
  Enum['present', 'absent'] $ensure      = 'present',
  String                    $app_name    = "${title}-${environment}",
  Optional[String]          $license_key = undef,
  Integer                   $portbase    = 4800
) {

  $log_directory = "/opt/payara/glassfish/domains/${title}/logs"

  include ::profiles
  include ::profiles::newrelic::java

  $default_attributes = {
                          ensure       => $ensure,
                          user         => 'glassfish',
                          passwordfile => '/home/glassfish/asadmin.pass',
                          portbase     => String($portbase)
                        }

  jvmoption { "Domain ${title} jvmoption -javaagent:/opt/newrelic/newrelic.jar":
    option  => '-javaagent:/opt/newrelic/newrelic.jar',
    require => Class['profiles::newrelic::java'],
    *       => $default_attributes
  }

  systemproperty { "Domain ${title} newrelic.config.file" :
    name  => 'newrelic.config.file',
    value => "/opt/payara/glassfish/domains/${title}/config/newrelic.yml",
    *     => $default_attributes
  }

  file { "Domain ${title} newrelic config file":
    ensure  => $ensure ? {
                 'present' => 'file',
                 'absent'  => 'absent'
               },
    path    => "/opt/payara/glassfish/domains/${title}/config/newrelic.yml",
    owner   => 'glassfish',
    group   => 'glassfish',
    content => template('profiles/glassfish/domain/newrelic.yaml.erb'),
    before  => Systemproperty["Domain ${title} newrelic.config.file"]
  }
}
