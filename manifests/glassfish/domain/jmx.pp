define profiles::glassfish::domain::jmx (
  Enum['present', 'absent'] $ensure   = 'present',
  Integer                   $portbase = 4800
) {

  include ::profiles

  $jvmoption_default_attributes = {
                                     ensure       => $ensure,
                                     user         => 'glassfish',
                                     passwordfile => '/home/glassfish/asadmin.pass',
                                     portbase     => String($portbase)
                                   }

  jvmoption { "Domain ${title} jvmoption -Dcom.sun.management.jmxremote":
    option => '-Dcom.sun.management.jmxremote',
    *      => $jvmoption_default_attributes
  }

  jvmoption { "Domain ${title} jvmoption -Dcom.sun.management.jmxremote.port=9003":
    option => '-Dcom.sun.management.jmxremote.port=9003',
    *      => $jvmoption_default_attributes
  }

  jvmoption { "Domain ${title} jvmoption -Dcom.sun.management.jmxremote.local.only=false":
    option => '-Dcom.sun.management.jmxremote.local.only=false',
    *      => $jvmoption_default_attributes
  }

  jvmoption { "Domain ${title} jvmoption -Dcom.sun.management.jmxremote.authenticate=false":
    option => '-Dcom.sun.management.jmxremote.authenticate=false',
    *      => $jvmoption_default_attributes
  }

  jvmoption { "Domain ${title} jvmoption -Dcom.sun.management.jmxremote.ssl=false":
    option => '-Dcom.sun.management.jmxremote.ssl=false',
    *      => $jvmoption_default_attributes
  }

  jvmoption { "Domain ${title} jvmoption -Djava.rmi.server.hostname=127.0.0.1":
    option => '-Djava.rmi.server.hostname=127.0.0.1',
    *      => $jvmoption_default_attributes
  }
}
