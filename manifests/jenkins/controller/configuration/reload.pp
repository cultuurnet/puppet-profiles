class profiles::jenkins::controller::configuration::reload inherits ::profiles {

  exec { 'jenkins configuration-as-code reload':
    command     => 'jenkins-cli reload-jcasc-configuration',
    user        => 'jenkins',
    refreshonly => true,
    logoutput   => 'on_failure',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin']
  }
}
