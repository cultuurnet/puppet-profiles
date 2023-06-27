define profiles::logstash::plugin (
  Enum['present', 'absent'] $ensure = 'present'
) {

  Exec {
    path    => '/bin:/usr/bin',
    cwd     => '/tmp',
    timeout => 1800
  }

  case $ensure {
    'present': {
      exec { "install-${title}":
        command => "/usr/share/logstash/bin/logstash-plugin install ${title}",
        unless  => "/usr/share/logstash/bin/logstash-plugin list ^${title}$"
      }
    }

    'absent': {
      exec { "remove-${title}":
        command => "/usr/share/logstash/bin/logstash-plugin remove ${title}",
        onlyif  => "/usr/share/logstash/bin/logstash-plugin list | grep -q ^${title}$"
      }
    }

    default: {
      fail "'ensure' should be 'present'"
    }
  }
}
