class profiles::jenkins::cli(
  String $admin_user,
  String $admin_password,
  String $version        = 'latest',
  String $server_url     = 'http://localhost:8080'
) {

  contain ::profiles

  include ::profiles::jenkins

  realize Apt::Source['publiq-jenkins']
  realize Profiles::Apt::Update['publiq-jenkins']

  package { 'jenkins-cli':
    ensure  => $version,
    require => Profiles::Apt::Update['publiq-jenkins']
  }

  file { '/etc/jenkins-cli/cli.conf':
    ensure  => 'file',
    mode    => '0644',
    content => template('profiles/jenkins/cli.conf.erb')
  }
}
