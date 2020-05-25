## This profile installs everything needed to get Jenkins up and running with all jobs and plugins it needs.
class profiles::jenkins (
  $credentials_file = '',
  $global_libraries_file  = '',
  $sslchain = '',
  $sslcert = '',
  $sslkey = '',
) {
  contain ::profiles
  contain ::profiles::java8
  include ruby
  $jenkins_port = 8080
  $apache_server = 'jenkins.publiq.be'

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
  }

  # Set the jenkins URL and admin email address.
  file {'jenkins.model.JenkinsLocationConfiguration.xml':
    ensure  => file,
    path    => '/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    require => Class['jenkins'],
    content => "<?xml version=\'1.1\' encoding=\'UTF-8\'?>
<jenkins.model.JenkinsLocationConfiguration>
  <adminAddress>jenkins@cultuurnet.be</adminAddress>
  <jenkinsUrl>https://${apache_server}/</jenkinsUrl>
</jenkins.model.JenkinsLocationConfiguration>",
  }

  Package['dpkg'] -> Class['::profiles::java8'] -> Class['jenkins'] -> File['jenkins.model.JenkinsLocationConfiguration.xml']

  realize Package['git']  #defined in packages.pp, installs git

  # ----------- Install Jenkins Plugins -----------
  # The puppet-jenkins module has functionality for adding plugins but you must install the dependencies also(not done automatically). 
  # This was tried but proved to be too much work. For example the delivery-pipeline-plugin has a total of 38 dependencies. 
  # It was decided to use the jenkins cli instead because it auto loads all the dependencies. 
  # We have to use the .jar manually because the name of the file was changed in jenkins itslef but the puppet plugin has not been updated yet,  
  # https://github.com/voxpupuli/puppet-jenkins/pull/945, this means we can not use jenkins::cli or jenkins::credentials and several other classes.

  $clitool = 'jenkins-cli'

  # We have made our own rake file that installs the cli(jar file) and adds a script for easy use, that is 
  # installed in the system path for easy use. The rake file can be found here: 
  # https://github.com/cultuurnet/tool-builder/tree/master/jenkins-cli 
  package{$clitool:
    name     => $clitool,
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

  # We use the import-credentials-as-xml because we can load many credentials fromm one xml file, unlike create-credentials-by-xml . 
  exec { 'import-credentials':
    command   => "${clitool} import-credentials-as-xml system::system::jenkins < ${credentials_file}",
    tries     => 10,
    try_sleep => 30,
  }

  Package['jenkins-cli'] -> Exec['delivery-pipeline-plugin'] -> Exec['workflow-cps-global-lib'] -> Exec['bitbucket'] -> Exec['workflow-aggregator'] -> File[$credentials_file] -> Exec['import-credentials'] -> Exec['blueocean']

  class{ 'apache':
    default_vhost => false,
  }

  apache::vhost { 'apt-private_80':
    docroot             => '/var/www/html',
    manage_docroot      => false,
    port                => '80',
    servername          => $apache_server,
    proxy_preserve_host => true,
    proxy_pass          =>
    {
      path =>  '/',
      url  => "http://localhost:${jenkins_port}/"
    }
  }

  apache::vhost { 'apt-private_443':
    docroot             => '/var/www/html',
    manage_docroot      => false,
    proxy_preserve_host => true,
    port                => '443',
    servername          => $apache_server,
    ssl                 => true,
    ssl_cert            => $sslcert,
    ssl_chain           => $sslchain,
    ssl_key             => $sslkey,
    proxy_pass          =>
    {
      path =>  '/',
      url  => "http://localhost:${jenkins_port}/"
    },
    require             => [
      File[$sslchain],
      File[$sslcert],
      File[$sslkey],
    ]
  }
}
