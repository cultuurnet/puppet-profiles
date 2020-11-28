## This profile installs everything needed to get Jenkins up and running with all jobs and plugins it needs.
class profiles::jenkins::server (
  String $adminpassword,
  $sslcert,
  $sslkey,
  $sshpublickey,
  $sslchain = '',
) {
  contain ::profiles
  contain ::profiles::java8

  include ::profiles::apt::keys
  include ::profiles::packages
  include ruby

  $jenkins_port = 8080
  $apache_server = 'jenkins.publiq.be'
  $adminuser = 'admin'
  $security_model = 'full_control'
  $helper_groovy = '/usr/share/jenkins/puppet_helper.groovy'

  realize Package['jq']

  apt::source { 'publiq-jenkins':
    location => "http://apt.uitdatabank.be/jenkins-${environment}",
    release  => $facts['lsbdistcodename'],
    repos    => 'main',
    require  => Class['profiles::apt::keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  profiles::apt::update { 'publiq-jenkins': }

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

  package { 'build-essential':
    ensure   => 'installed'
  }

  # This will install and configure jenkins.
  class { 'jenkins':
    repo         => false,
    cli          => false,
    install_java => false,
    require      => Profiles::Apt::Update['publiq-jenkins']
  }

  sudo::conf { 'jenkins':
    priority => '10',
    content  => 'jenkins ALL=(ALL) NOPASSWD: ALL',
    require  => Class['jenkins']
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
    #source => '/vagrant/puppet/files/jenkins-prod01.eu-west-1.compute.internal/id_rsa',
  }
  file {"${sshdir}/known_hosts":
    ensure => file,
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0644',
    source => 'puppet:///private/known_hosts',
    #source => '/vagrant/puppet/files/jenkins-prod01.eu-west-1.compute.internal/known_hosts',
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
  package{ $clitool:
    name     => $clitool,
    provider => apt,
    require  => Profiles::Apt::Update['publiq-jenkins']
  }

  # ----------- Setup security ----------------------------------------------------
  #Make sure the groovy script from the jenkins puppet module is available
  file { $helper_groovy:
    ensure => file,
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0644',
    source => 'puppet:///modules/jenkins/puppet_helper.groovy',
    #source => '/vagrant/puppet/modules/jenkins/files/puppet_helper.groovy',
  }

  profiles::jenkins::plugin { 'mailer':
    admin_user     => $adminuser,
    admin_password => $adminpassword
  }

  # Create first user
  exec { 'create-jenkins-user-admin':
    command   => "cat ${helper_groovy} | ${clitool} groovy = create_or_update_user ${adminuser} \"jenkins@publiq.be\" ${adminpassword} \"${adminuser}\" \"\"",
    tries     => 10,
    try_sleep => 30,
    require   => [ Package[$clitool], Class['jenkins'], File[$helper_groovy], Profiles::Jenkins::Plugin['mailer']],
    unless    => "cat ${helper_groovy} | ${clitool} -auth ${adminuser}:${adminpassword} groovy = user_info ${adminuser}", #Check if the admin user exists
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
instance.save()' | ${clitool} -auth ${adminuser}:${adminpassword} groovy =",
    unless    => "cat ${helper_groovy} | ${clitool} -auth ${adminuser}:${adminpassword} groovy = get_authorization_strategyname | grep -q -e '^${security_model}\$'",
    tries     => 10,
    try_sleep => 30,
    require   => [Class['jenkins'], Exec['create-jenkins-user-admin']],
  }

  Package['dpkg'] -> Class['::profiles::java8'] -> Class['jenkins'] -> File[$sshdir] -> File['jenkins.model.JenkinsLocationConfiguration.xml']

  realize Package['git']  #defined in packages.pp, installs git

  # ----------- Install Jenkins Plugins and Credentials-----------
  # The puppet-jenkins module has functionality for adding plugins but you must install the dependencies manually(not done automatically).
  # This was tried but proved to be too much work. For example the delivery-pipeline-plugin has a total of 38 dependencies.
  # It was decided to use the jenkins cli instead because it auto loads all the dependencies.
  # We have to use the .jar manually because the name of the file was changed in jenkins itslef but the puppet plugin has not been updated yet,
  # https://github.com/voxpupuli/puppet-jenkins/pull/945, this means we can not use jenkins::cli or jenkins::credentials and several other classes.

  profiles::jenkins::plugin { 'delivery-pipeline-plugin':
    admin_user     => $adminuser,
    admin_password => $adminpassword
  }

  profiles::jenkins::plugin { 'workflow-cps-global-lib':
    admin_user     => $adminuser,
    admin_password => $adminpassword
  }

  file { '/var/lib/jenkins/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///private/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml',
    #source  => '/vagrant/puppet/files/jenkins-prod01.eu-west-1.compute.internal/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml',
    require => Profiles::Jenkins::Plugin['workflow-cps-global-lib'],
  }

  profiles::jenkins::plugin { 'bitbucket':
    admin_user     => $adminuser,
    admin_password => $adminpassword
  }

  profiles::jenkins::plugin { 'workflow-aggregator':
    admin_user     => $adminuser,
    admin_password => $adminpassword
  }

  profiles::jenkins::plugin { 'ssh-steps':
    admin_user     => $adminuser,
    admin_password => $adminpassword
  }

  profiles::jenkins::plugin { 'blueocean':
    admin_user     => $adminuser,
    admin_password => $adminpassword
  }

  profiles::jenkins::plugin { 'copyartifact':
    admin_user     => $adminuser,
    admin_password => $adminpassword
  }

  profiles::jenkins::plugin { 'pipeline-utility-steps':
    admin_user     => $adminuser,
    admin_password => $adminpassword
  }

  profiles::jenkins::plugin { 'slack':
    admin_user     => $adminuser,
    admin_password => $adminpassword
  }

  # We use the import-credentials-as-xml because we can load many credentials fromm one xml file, unlike create-credentials-by-xml.
  $credentials_file = '/usr/share/jenkins/credentials.xml'
  file{$credentials_file:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///private/credentials.xml',
    #source => '/vagrant/puppet/files/jenkins-prod01.eu-west-1.compute.internal/credentials.xml',
  }
  exec { 'import-credentials':
    command   => "${clitool} -auth ${adminuser}:${adminpassword} import-credentials-as-xml system::system::jenkins < ${credentials_file}",
    tries     => 10,
    try_sleep => 30,
    require   => [ Package[$clitool], File[$credentials_file]],
  }

  Profiles::Jenkins::Plugin['delivery-pipeline-plugin'] -> Profiles::Jenkins::Plugin['workflow-cps-global-lib'] -> Profiles::Jenkins::Plugin['bitbucket'] -> Profiles::Jenkins::Plugin['workflow-aggregator']

  # ----------- Install the Apache server and vhosts for HTTP and HTTPS -----------
  class{ 'apache':
    default_vhost => false,
  }

  apache::vhost { "${apache_server}_80":
    docroot         => '/var/www/html',
    manage_docroot  => false,
    port            => '80',
    servername      => $apache_server,
    redirect_source => '/',
    redirect_dest   => "https://${apache_server}/",
    redirect_status => 'permanent',
  }

  apache::vhost { "${apache_server}_443":
    docroot               => '/var/www/html',
    manage_docroot        => false,
    proxy_preserve_host   => true,
    allow_encoded_slashes => 'nodecode',
    port                  => '443',
    servername            => $apache_server,
    ssl                   => true,
    ssl_cert              => $sslcert,
    ssl_chain             => $sslchain,
    ssl_key               => $sslkey,

    setenv                => ['force-proxy-request-1.0 1','proxy-nokeepalive 1'],
    request_headers       => ['set X-Forwarded-Proto "https"','set X-Forwarded-Port "443"'],

    proxy_pass            =>
    {
      path         =>  '/',
      url          => "http://localhost:${jenkins_port}/",
      keywords     => ['nocanon'],
      reverse_urls => ["http://localhost:${jenkins_port}/","http://${apache_server}/"],
    },

    require               => [
      File[$sslchain],
      File[$sslcert],
      File[$sslkey],
    ]
  }
}
