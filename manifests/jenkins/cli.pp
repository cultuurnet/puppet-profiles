class profiles::jenkins::cli(
  Boolean $manage_credentials = false,
  String  $version            = 'latest',
  String  $user               = lookup('profiles::jenkins::controller::admin_user', String, 'first', ''),
  String  $password           = lookup('profiles::jenkins::controller::admin_password', String, 'first', ''),
  String  $controller_url     = lookup('profiles::jenkins::controller::url', String, 'first', 'http://localhost:8080/')
) inherits ::profiles {

  include ::profiles::java
  include ::profiles::jenkins::repositories

  $config_path                 = '/etc/jenkins-cli/cli.conf'

  realize Profiles::Apt::Update['publiq-jenkins']

  package { 'jenkins-cli':
    ensure  => $version,
    require => [ Profiles::Apt::Update['publiq-jenkins'], Class['profiles::java']]
  }

  file { 'jenkins-cli_configdir':
    ensure  => 'directory',
    path    => dirname($config_path),
    mode    => '0755',
    require => Package['jenkins-cli']
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

  shellvar { 'CONTROLLER_URL':
    ensure   => 'present',
    variable => 'CONTROLLER_URL',
    value    => $controller_url,
    target   => $config_path,
    require  => File['jenkins-cli_config']
  }
}
