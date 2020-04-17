## This profile installs jenkins, adds plugins, and ....
class profiles::jenkins ()
{
  contain ::profiles
  contain ::profiles::java8

  package { 'dpkg':
    ensure   => latest,
    name     => 'dpkg',
    provider => apt,
  }

  realize Package['git']  #defined in packages.pp

  package { 'bundler':
    ensure => present,
  }

  # This will install aptly and set the s3_publish_endpoints parameter.
  class { 'jenkins':
    cli          => false,
    install_java => false,
    require      => Class['::profiles::java8'],
  }

  $jar = "${jenkins::libdir}/cli-2.222.1.jar"
  $extract_jar = "jar -xf ${jenkins::libdir}/jenkins.war WEB-INF/lib/cli-2.222.1.jar"
  $move_jar = "mv WEB-INF/lib/cli-2.222.1.jar ${jar}"
  $remove_dir = 'rm -rf WEB-INF'

  exec { 'check-jenkins-cli-version':
    command => "java -jar ${jar} -s http:// localhost:8080/ list-plugins",
  }

}
