class profiles::jenkins::controller::install (
  String          $version     = 'latest'
) inherits ::profiles {

  include ::profiles::groups
  include ::profiles::users

  $config_dir = '/var/lib/jenkins/casc_config'

  realize Group['jenkins']
  realize User['jenkins']

  realize Apt::Source['publiq-jenkins']

  package { 'jenkins':
    ensure  => $version,
    require => [ User['jenkins'], Apt::Source['publiq-jenkins']]
  }

  file { 'casc_config':
    ensure  => 'directory',
    path    => $config_dir,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => Package['jenkins']
  }

  shellvar { 'JAVA_ARGS':
    ensure   => 'present',
    variable => 'JAVA_ARGS',
    target   => '/etc/default/jenkins',
    value    => "-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=${config_dir}",
    require  => File['casc_config']
  }
}
