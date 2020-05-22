## This profile installs everything needed to get Jenkins up and running with all jobs and plugins it needs.
class profiles::jenkins (
  $credentials_file = '',
  $global_libraries_file  = '',
) {
  contain ::profiles
  contain ::profiles::java8
  include ruby

  # This will install the ruby dev package and bundler
  class{'ruby::dev':
    bundler_provider => 'apt',
  }

  # we have to intall this manually because of https://github.com/ffi/ffi/issues/607
  package { 'libffi-dev':
    name     => 'libffi-dev',
    provider => apt,
    require  => Class['ruby::dev']
  }

  package { 'dpkg':       #we need to upgrade dpkg to 5.8 for the jenkins install to work correctly
    ensure   => latest,
    name     => 'dpkg',
    provider => apt,
  }

  # This will install and configure jenkins.
  class { 'jenkins':
    cli          => false,
    install_java => false,
    config_hash  => {
      'JENKINS_URL' => { 'value' => 'https://jenkins.publiq.be/' },
    }
  }

  Package['dpkg'] -> Class['::profiles::java8'] -> Class['jenkins'] # -> Class['ruby::dev'] #Package['bundler']

  realize Package['git']  #defined in packages.pp, installs git

  # ----------- Install Jenkins Plugins -----------
  # The puppet-jenkins module has functionality for adding plugins but you must install the dependencies also(not done automatically). 
  # This was tried but proved to be too much work. For example the delivery-pipeline-plugin has a total of 38 dependencies. 
  # It was decided to use the jenkins cli instead because it auto loads all the dependencies. 
  # We have to use the .jar manually because the name of the file was changed in jenkins itslef but the puppet plugin has not been updated yet,  
  # https://github.com/voxpupuli/puppet-jenkins/pull/945, this means we can not use jenkins::cli or jenkins::credentials and several other classes.

  $clitool = 'jenkins-cli'

  # We extract the cli jar and rename it. It will have a name like cli-2.222.1.jar but we will rename it to something static, jenkins-cli.jar. We do this
  # becuase jar name will be continuesly changing with every version.
  # If the directory is not made the rm will fail, that is why we don't use -f
  #exec{ 'install-cli-jar' :
  #  command => "jar -xf ${jenkins::params::libdir}/jenkins.war WEB-INF/lib/cli-2.222.3.jar && 
  #              mv WEB-INF/lib/cli-2.222.3.jar ${jar} && 
  #              rm -rf WEB-INF",
  #  require => Class['jenkins'],
  #}
  package{'jenkins-cli':
    name     => 'jenkins-cli',
    provider => apt,
    require  => Class['jenkins'],
  }

  #Installs the jenkins plugin delivery-pipeline-plugin. The cli will detect if the plugin is already present and do nothing if it is. 
  exec { 'delivery-pipeline-plugin':
    command   => "${clitool} install-plugin delivery-pipeline-plugin -restart",
    tries     => 12,
    try_sleep => 30,
  }

  #Installs the jenkins shared groovy libraries(DSL). 
  exec { 'workflow-cps-global-lib':
    command   => "${clitool} install-plugin workflow-cps-global-lib -restart",
    tries     => 12,
    try_sleep => 30,
    require   => File[$global_libraries_file],
  }

  #Installs the jenkins plugin templating engine. The cli will detect if the plugin is already present and do nothing if it is.
  exec { 'bitbucket':
    command   => "${clitool} install-plugin bitbucket -restart",
    tries     => 12,
    try_sleep => 30,
  }

  #Installs the pipleine plugin, we need this for PipelineAsCode. The cli will detect if the plugin is already present and do nothing if it is.
  exec { 'workflow-aggregator':
    command   => "${clitool} install-plugin workflow-aggregator -restart",
    tries     => 12,
    try_sleep => 30,
  }

  #Installs the pipleine plugin, we need this for PipelineAsCode. The cli will detect if the plugin is already present and do nothing if it is.
  exec { 'blueocean':
    command   => "${clitool} install-plugin blueocean -restart",
    tries     => 12,
    try_sleep => 30,
  }

  # TODO: Blue Ocean

  # We use the import-credentials-as-xml because we can load many credentials fromm one xml file, unlike create-credentials-by-xml . 
  exec { 'import-credentials':
    command   => "${clitool} import-credentials-as-xml system::system::jenkins < ${credentials_file}",
    tries     => 10,
    try_sleep => 30,
  }

  Package['jenkins-cli'] -> Exec['delivery-pipeline-plugin'] -> Exec['workflow-cps-global-lib'] -> Exec['bitbucket'] -> Exec['workflow-aggregator'] -> Exec['blueocean'] -> File[$credentials_file] -> Exec['import-credentials']

}
