## This profile installs everything needed to get Jenkins up and running with all jobs and plugins it needs.
class profiles::jenkins (
  String $adminpassword,
  $sslchain = '',
  $sslcert = '',
  $sslkey = '',
  $sshpublickey = '',
) {
  contain ::profiles
  contain ::profiles::java8
  include ruby
  $jenkins_port = 8080
  $apache_server = 'jenkins.publiq.be'
  $adminuser = 'admin'
  $security_model = 'full_control'
  $helper_groovy = '/usr/share/jenkins/puppet_helper.groovy'

  # This will install the ruby dev package and bundler
  class{'ruby::dev':
    bundler_provider => 'apt',
  }

  # we have to install this manually because of https://github.com/ffi/ffi/issues/607
  package { 'libffi-dev':
    name     => 'libffi-dev',
    provider => apt,
    require  => Class['ruby::dev']
  }

  package { 'dpkg':       #we need to upgrade dpkg to 5.8 for the jenkins install to work correctly, default ubuntu 14.04 is 5.7
    ensure   => latest,
    name     => 'dpkg',
    provider => apt,
  }

  # This will install and configure jenkins.
  class { 'jenkins':
    cli          => false,
    install_java => false,
  }

  # This folder will hold all the files needed for a special ssh key. When you run something in a job 
  # like 'librarian-puppet install' it expects there to be an ssh key already on the operating system. 
  # It can't see/use the one made in jenkins.
  $sshdir = '/var/lib/jenkins/.ssh'
  file {$sshdir:
    ensure => directory,
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0755',
  }
  file {"${sshdir}/id_rsa":
    ensure => file,
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0400',
    source => 'puppet:///private/id_rsa',
  }
  file {"${sshdir}/known_hosts":
    ensure => file,
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0644',
    source => 'puppet:///private/known_hosts',
  }
  file {"${sshdir}/id_rsa.pub":
    ensure  => file,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    content => $sshpublickey,
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
  <adminAddress>jenkins@publiq.be</adminAddress>
  <jenkinsUrl>https://${apache_server}/</jenkinsUrl>
</jenkins.model.JenkinsLocationConfiguration>",
  }

  # We have made our own rake file that installs the cli(jar file) and adds a script for easy use, that is 
  # installed in the system path for easy use. The rake file can be found here: 
  # https://github.com/cultuurnet/tool-builder/tree/master/jenkins-cli 
  $clitool = 'jenkins-cli'
  package{$clitool:
    name     => $clitool,
    provider => apt,
    require  => Class['jenkins'],
  }

  # ----------- Setup security ----------------------------------------------------
  #Make sure the groovy script from the jenkins puppet module is available
  file { $helper_groovy:
    source => 'puppet:///modules/jenkins/puppet_helper.groovy',
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0444',
  }

  #We need this plugin to create our first user
  exec { 'mailer':
    command   => "${clitool} install-plugin mailer -restart",
    tries     => 12,
    try_sleep => 30,
  }

  # Create first user
  exec { 'create-jenkins-user-admin':
    command   => "cat ${helper_groovy} | jenkins-cli groovy = create_or_update_user ${adminuser} \"jenkins@publiq.be\" ${adminpassword} \"${adminuser}\" \"\"",
    tries     => 10,
    try_sleep => 30,
    require   => [Package[$clitool],Class['jenkins']],
  }

  # Set security/strategy policy (jenkins database + no sign up, logged-in uses can do anything + no anonymous read )
  exec { "jenkins-security-${security_model}":
    command   => "echo 'import jenkins.model.*
def instance = Jenkins.getInstance()
import hudson.security.*
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
def realm = new HudsonPrivateSecurityRealm(false)
instance.setSecurityRealm(realm)
instance.save()' | ${clitool} -auth admin:3d8hk9s groovy =",
    unless    => "cat ${helper_groovy} | ${clitool} groovy = get_authorization_strategyname | grep -q -e '^${security_model}\$'",
    tries     => 10,
    try_sleep => 30,
    require   => [Package[$clitool],Class['jenkins']],
  }

  Package['dpkg'] -> Class['::profiles::java8'] -> Class['jenkins'] -> File[$sshdir] -> File['jenkins.model.JenkinsLocationConfiguration.xml'] -> Package['jenkins-cli'] -> File[$helper_groovy] -> Exec['mailer'] -> Exec['create-jenkins-user-admin'] -> Exec["jenkins-security-${security_model}"]

  realize Package['git']  #defined in packages.pp, installs git

  # ----------- Install Jenkins Plugins and Credentials-----------
  # The puppet-jenkins module has functionality for adding plugins but you must install the dependencies manually(not done automatically). 
  # This was tried but proved to be too much work. For example the delivery-pipeline-plugin has a total of 38 dependencies. 
  # It was decided to use the jenkins cli instead because it auto loads all the dependencies. 
  # We have to use the .jar manually because the name of the file was changed in jenkins itslef but the puppet plugin has not been updated yet,  
  # https://github.com/voxpupuli/puppet-jenkins/pull/945, this means we can not use jenkins::cli or jenkins::credentials and several other classes.

  #Installs the jenkins plugin delivery-pipeline-plugin. The cli will detect if the plugin is already present and do nothing if it is. 
  exec { 'delivery-pipeline-plugin':
    command   => "${clitool} -auth ${adminuser}:${adminpassword} install-plugin delivery-pipeline-plugin -restart",
    tries     => 12,
    try_sleep => 30,
    require   => Package[$clitool],
  }

  # We need this plugin for libraries used in PipeLineAsCode. After the plugin is installed we add a config file for it.
  exec { 'workflow-cps-global-lib':
    command   => "${clitool} -auth ${adminuser}:${adminpassword} install-plugin workflow-cps-global-lib -restart",
    tries     => 12,
    try_sleep => 30,
  }
  file { '/var/lib/jenkins/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///private/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml',
    require => Exec['workflow-cps-global-lib'],
  }

  # We need this to connect to bitbucket. The cli will detect if the plugin is already present and do nothing if it is.
  exec { 'bitbucket':
    command   => "${clitool} -auth ${adminuser}:${adminpassword} install-plugin bitbucket -restart",
    tries     => 12,
    try_sleep => 30,
    require   => Package[$clitool],
  }

  # This plugin is adds libraries need for PipeLineAsCode. The cli will detect if the plugin is already present and do nothing if it is.
  exec { 'workflow-aggregator':
    command   => "${clitool} -auth ${adminuser}:${adminpassword} install-plugin workflow-aggregator -restart",
    tries     => 12,
    try_sleep => 30,
    require   => Package[$clitool],
  }

  # This plugin makes the pipeline view more user friendly and easier to debug.
  exec { 'blueocean':
    command   => "${clitool} -auth ${adminuser}:${adminpassword} install-plugin blueocean -restart",
    tries     => 12,
    try_sleep => 30,
    require   => Package[$clitool],
  }

  # We use the import-credentials-as-xml because we can load many credentials fromm one xml file, unlike create-credentials-by-xml.
  $credentials_file = '/usr/share/jenkins/credentials.xml'
  file{$credentials_file:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///private/credentials.xml',
  }
  exec { 'import-credentials':
    command   => "${clitool} -auth ${adminuser}:${adminpassword} import-credentials-as-xml system::system::jenkins < ${credentials_file}",
    tries     => 10,
    try_sleep => 30,
    require   => Package[$clitool],
  }

  Exec['delivery-pipeline-plugin'] -> Exec['workflow-cps-global-lib'] -> Exec['bitbucket']-> Exec['workflow-aggregator'] -> File[$credentials_file] -> Exec['import-credentials'] -> Exec['blueocean']



  # ----------- Install the Apache server and vhosts for HTTP and HTTPS -----------
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
