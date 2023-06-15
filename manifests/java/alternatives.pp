class profiles::java::alternatives (
  Integer[8, 11]     $default_version,
  Enum['jre', 'jdk'] $distribution    = 'jre',
  Boolean            $headless        = true
) inherits ::profiles {

  $java_home = "/usr/lib/jvm/java-${default_version}-openjdk-amd64"

  shellvar { 'JAVA_HOME':
    ensure => 'present',
    target => '/etc/environment',
    value  => $java_home
  }

  case $default_version {
    8: {
         $jre_home  = "${java_home}/jre"
         $jre_commands_headless = ['rmid', 'java', 'keytool', 'jjs', 'pack200', 'rmiregistry', 'unpack200', 'orbd', 'servertool', 'tnameserv']
         $jdk_commands_headless = ['idlj', 'jdeps', 'wsimport', 'rmic', 'jinfo', 'jsadebugd', 'native2ascii', 'jstat', 'javac', 'javah', 'clhsdb', 'jstack', 'jrunscript', 'javadoc', 'javap', 'jar', 'xjc', 'hsdb', 'schemagen', 'jps', 'extcheck', 'jmap', 'jstatd', 'jhat', 'jdb', 'serialver', 'jfr', 'wsgen', 'jcmd', 'jarsigner']
         if $headless {
           $jre_commands = $jre_commands_headless
           $jdk_commands = $jdk_commands_headless
         } else {
           $jre_commands = $jre_commands_headless + ['policytool']
           $jdk_commands = $jdk_commands_headless + ['appletviewer', 'jconsole']
         }
    }
    11: {
          $jre_home  = $java_home
          $jre_commands_headless = ['java', 'jjs', 'keytool', 'rmid', 'rmiregistry', 'pack200', 'unpack200']
          $jdk_commands_headless = ['jar', 'jarsigner', 'javac', 'javadoc', 'javap', 'jcmd', 'jdb', 'jdeprscan', 'jdeps', 'jfr', 'jimage', 'jinfo', 'jlink', 'jmap', 'jmod', 'jps', 'jrunscript', 'jshell', 'jstack', 'jstat', 'jstatd', 'rmic', 'serialver', 'jaotc', 'jhsdb']
          if $headless {
            $jre_commands = $jre_commands_headless
            $jdk_commands = $jdk_commands_headless
          } else {
            $jre_commands = $jre_commands_headless
            $jdk_commands = $jdk_commands_headless + ['jconsole']
          }
    }
  }

  $jre_commands.each |$command| {
    alternatives { $command:
      path    => "${jre_home}/bin/${command}"
    }
  }

  if $distribution == 'jdk' {
    $jdk_commands.each |$command| {
      alternatives { $command:
        path    => "${java_home}/bin/${command}"
      }
    }
  }
}
