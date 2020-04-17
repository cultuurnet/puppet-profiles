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

  $jar = "${jenkins::params::libdir}/cli-2.222.1.jar"
  exec{ 'install-cli-jar' :
    command => "jar -xf ${jenkins::params::libdir}/jenkins.war WEB-INF/lib/cli-2.222.1.jar ;
                mv WEB-INF/lib/cli-2.222.1.jar ${jar} ; 
                rm -rf WEB-INF"
  }

  exec { 'check-jenkins-cli-version':
    command => "java -jar ${jar} -s http://localhost:8080/ list-plugins",
  }

  exec { 'echo':
    command => "echo Dude ${jenkins::params::libdir}",
  }

}
