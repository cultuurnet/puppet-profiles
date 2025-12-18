define profiles::logstash::plugin (
  Enum['present', 'absent'] $ensure = 'present'
) {

  $exec_default_attributes = {
                               path      => '/bin:/usr/bin',
                               logoutput => 'on_failure',
                               cwd       => '/',
                               timeout   => 1800
                             }

  case $ensure {
    'present': {
      exec { "install-${title}":
        command => "/usr/share/logstash/bin/logstash-plugin install ${title}",
        unless  => "/usr/share/logstash/bin/logstash-plugin list ^${title}$",
        *       => $exec_default_attributes
      }
    }
    'absent': {
      exec { "remove-${title}":
        command => "/usr/share/logstash/bin/logstash-plugin remove ${title}",
        onlyif  => "/usr/share/logstash/bin/logstash-plugin list ^${title}$",
        *       => $exec_default_attributes
      }
    }
    default: {
      fail "'ensure' should be 'present' or 'absent'"
    }
  }
}
