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

  # This will install and configure jenkins.
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

  # ----------- Install Jenkins Plugins -----------
  # The puppet-jenkins module has functionality for adding plugins but you must install the dependencies also(not done automatically). This was tried but
  # proved to be too much work. For example the delivery-pipeline-plugin has a total of 38 dependencies. 
  # It was decided to use the jenkins cli instead because it auto loads all the dependencies. 
  # We have to use the .jar manually because the name of the file was changed in jenkins itslef but the puppet plugin has not been updated yet,  https://github.com/voxpupuli/puppet-jenkins/pull/945

  #Installs the jenkins plugin delivery-pipeline-plugin. The cli will detect if the plugin is already present and do nothing if it is. 
  exec { 'delivery-pipeline-plugin':
    command => "java -jar ${jar} -s http://localhost:8080/ install-plugin delivery-pipeline-plugin -restart",
  }

  #Installs the jenkins plugin templating engine. The cli will detect if the plugin is already present and do nothing if it is.
  exec { 'templating-engine':
    command => "java -jar ${jar} -s http://localhost:8080/ install-plugin templating-engine -restart",
  }

  #Installs the jenkins plugin templating engine. The cli will detect if the plugin is already present and do nothing if it is.
  exec { 'bitbucket':
    command => "java -jar ${jar} -s http://localhost:8080/ install-plugin bitbucket -restart",
  }
}
