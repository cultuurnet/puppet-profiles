class profiles::jenkins::controller::install (
  String $version = 'latest'
) inherits ::profiles {

  $config_dir = '/var/lib/jenkins/casc_config'
  $java_opts  = "-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=${config_dir}"

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
    value    => $java_opts,
    require  => File['casc_config']
  }

  systemd::dropin_file { 'override.conf':
    unit    => 'jenkins.service',
    content => "[Service]\nEnvironment=\"JAVA_OPTS=${java_opts}\""
  }
}
