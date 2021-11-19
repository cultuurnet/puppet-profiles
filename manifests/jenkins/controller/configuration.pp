class profiles::jenkins::controller::configuration inherits ::profiles {

  profiles::jenkins::plugin { 'configuration-as-code': }
  profiles::jenkins::plugin { 'swarm': }

  exec { 'jenkins configuration-as-code reload':
    command     => 'jenkins-cli reload-jcasc-configuration',
    user        => 'jenkins',
    refreshonly => true,
    logoutput   => 'on_failure',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    require     => Profiles::Jenkins::Plugin['configuration-as-code']
  }
}
