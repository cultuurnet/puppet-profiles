class profiles::jenkins::cli(
  Boolean $manage_credentials = true,
  String  $version            = 'latest',
  String  $user               = lookup('profiles::jenkins::controller::admin_user', String, 'first', ''),
  String  $password           = lookup('profiles::jenkins::controller::admin_password', String, 'first', ''),
  String  $server_url         = lookup('profiles::jenkins::controller::server_url', String, 'first', 'http://localhost:8080/')
) inherits ::profiles {

  include ::profiles::java
  include ::profiles::jenkins::repositories

  $config_path                 = '/etc/jenkins-cli/cli.conf'

  realize Profiles::Apt::Update['publiq-jenkins']

  package { 'jenkins-cli':
    ensure  => $version,
    require => [ Profiles::Apt::Update['publiq-jenkins'], Class['profiles::java']]
  }

  file { 'jenkins-cli_config':
    ensure  => 'file',
    path    => $config_path,
    mode    => '0644',
    require => Package['jenkins-cli']
  }

  if $manage_credentials {
    class { ::profiles::jenkins::cli::credentials:
      user     => $user,
      password => $password,
      require  => File['jenkins-cli_config']
    }
  }

  shellvar { 'JENKINS_URL':
    ensure   => 'present',
    variable => 'JENKINS_URL',
    value    => $server_url,
    target   => $config_path,
    require  => File['jenkins-cli_config']
  }
}
