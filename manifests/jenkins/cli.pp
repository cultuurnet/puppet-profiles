class profiles::jenkins::cli(
  String $user       = lookup('profiles::jenkins::controller::admin_user', String, 'first', ''),
  String $password   = lookup('profiles::jenkins::controller::admin_password', String, 'first', ''),
  String $version    = 'latest',
  String $server_url = 'http://localhost:8080'
) {

  contain ::profiles

  include ::profiles::jenkins

  realize Profiles::Apt::Update['publiq-jenkins']

  package { 'jenkins-cli':
    ensure  => $version,
    require => Profiles::Apt::Update['publiq-jenkins']
  }

  file { '/etc/jenkins-cli/cli.conf':
    ensure  => 'file',
    mode    => '0644',
    content => template('profiles/jenkins/cli.conf.erb'),
    require => Package['jenkins-cli']
  }
}
