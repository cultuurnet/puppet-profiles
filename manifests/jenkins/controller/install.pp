class profiles::jenkins::controller::install (
  String     $version                 = 'latest',
  Integer[1] $session_timeout_minutes = 480
) inherits ::profiles {

  $config_dir   = '/var/lib/jenkins/casc_config'
  $java_opts    = [
    '-Djava.awt.headless=true',
    '-Djenkins.install.runSetupWizard=false',
    "-Dcasc.jenkins.config=${config_dir}",
    '-Dhudson.cli.CLIAction.ACCEPT_URL_FROM_REQUEST=true',
  ]
  $session_eviction_seconds = Integer($session_timeout_minutes) * 60
  $jenkins_args = [
    "--sessionTimeout=${session_timeout_minutes}",
    "--sessionEviction=${session_eviction_seconds}",
  ]

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
    value    => $java_opts.join(' '),
    require  => File['casc_config']
  }

  shellvar { 'JENKINS_ARGS':
    ensure   => 'present',
    variable => 'JENKINS_ARGS',
    target   => '/etc/default/jenkins',
    value    => $jenkins_args.join(' '),
    require  => File['casc_config']
  }

  systemd::dropin_file { 'override.conf':
    unit    => 'jenkins.service',
    content => "[Service]\nEnvironment=\"JAVA_OPTS=${java_opts.join(' ')}\"\nEnvironment=\"JENKINS_ARGS=${jenkins_args.join(' ')}\""
  }
}
