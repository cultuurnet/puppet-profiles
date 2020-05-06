## This profile installs everything needed to get Jenkins up and running with all jobs and plugins it needs.
class profiles::jenkins (
  $bitbucket_credential_file = '',
  $global_libraries_file  = '',
  $infrastructure_pipeline_file = '',
) {
  contain ::profiles
  contain ::profiles::java8

  realize Package['git']  #defined in packages.pp, installs git

  package { 'dpkg':       #we need to upgrade dpkg to 5.8 for the jenkins install to work correctly
    ensure   => latest,
    name     => 'dpkg',
    provider => apt,
  }

  # This will install and configure jenkins.
  class { 'jenkins':
    cli          => false,
    install_java => false,
  }

  package { 'bundler':    #install bundler
    ensure => present,
  }

  package { 'puppet':
    ensure => present,
  }

  Package['dpkg'] -> Class['::profiles::java8'] -> Class['jenkins'] -> Package['bundler'] -> Package['puppet']

  # ----------- Install Jenkins Plugins -----------
  # The puppet-jenkins module has functionality for adding plugins but you must install the dependencies also(not done automatically). 
  # This was tried but proved to be too much work. For example the delivery-pipeline-plugin has a total of 38 dependencies. 
  # It was decided to use the jenkins cli instead because it auto loads all the dependencies. 
  # We have to use the .jar manually because the name of the file was changed in jenkins itslef but the puppet plugin has not been updated yet,  
  # https://github.com/voxpupuli/puppet-jenkins/pull/945, this means we can not use jenkins::cli or jenkins::credentials and several other classes.

  $jar = "${jenkins::params::libdir}/cli-2.222.3.jar"

  # We extract the cli jar and rename it. It will have a name like cli-2.222.1.jar but we will rename it to something static, jenkins-cli.jar. We do this
  # becuase jar name will be continuesly changing with every version.
  # If the directory is not made the rm will fail, that is why we don't use -f
  exec{ 'install-cli-jar' :
    command => "jar -xf ${jenkins::params::libdir}/jenkins.war WEB-INF/lib/cli-2.222.3.jar && 
                mv WEB-INF/lib/cli-2.222.3.jar ${jar} && 
                rm -rf WEB-INF",
    require => Class['jenkins'],
  }

  #Creates the credential that will be used to clone depos from bitbucket. 
  exec { 'create-bitbucket-credential':
    command   => "java -jar ${jar} -s http://localhost:8080/ create-credentials-by-xml system::system::jenkins _  < ${bitbucket_credential_file}",
    tries     => 10,
    try_sleep => 30,
    returns   => [0, 1],  # 1 is returned if the user already exists which is ok
    require   => [File[$bitbucket_credential_file], Exec['install-cli-jar']],
  }

  #Installs the jenkins plugin delivery-pipeline-plugin. The cli will detect if the plugin is already present and do nothing if it is. 
  exec { 'delivery-pipeline-plugin':
    command   => "java -jar ${jar} -s http://localhost:8080/ install-plugin delivery-pipeline-plugin -restart",
    tries     => 10,
    try_sleep => 30,
    require   => Exec['install-cli-jar'],
  }

  #Installs the jenkins shared groovy libraries(DSL). 
  exec { 'workflow-cps-global-lib':
    command   => "java -jar ${jar} -s http://localhost:8080/ install-plugin workflow-cps-global-lib -restart",
    tries     => 10,
    try_sleep => 30,
    require   => File[$global_libraries_file]
  }

  #Installs the jenkins plugin templating engine. The cli will detect if the plugin is already present and do nothing if it is.
  exec { 'bitbucket':
    command   => "java -jar ${jar} -s http://localhost:8080/ install-plugin bitbucket -restart",
    tries     => 10,
    try_sleep => 30,
  }

  #Installs the pipleine plugin, we need this for PipelineAsCode. The cli will detect if the plugin is already present and do nothing if it is.
  exec { 'workflow-aggregator':
    command   => "java -jar ${jar} -s http://localhost:8080/ install-plugin workflow-aggregator -restart",
    tries     => 10,
    try_sleep => 30,
  }

  # TODO: pbulic and private keys

  # TODO: Blue Ocean



  Exec['install-cli-jar'] -> Exec['create-bitbucket-credential'] -> Exec['delivery-pipeline-plugin'] -> Exec['workflow-cps-global-lib'] -> Exec['bitbucket'] -> Exec['workflow-aggregator'] -> File[$infrastructure_pipeline_file]

}
