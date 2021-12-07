class profiles::jenkins::node(
  String                         $version        = 'latest',
  String                         $user           = 'admin',
  String                         $password       = lookup('profiles::jenkins::controller::admin_password', String, 'first', ''),
  String                         $controller_url = lookup('profiles::jenkins::controller::url', String, 'first', 'http://localhost:8080/'),
  Integer                        $executors      = 1,
  Variant[String, Array[String]] $labels         = []

) inherits ::profiles {

  include ::profiles::groups
  include ::profiles::users
  include ::profiles::java
  include ::profiles::jenkins::repositories
  include ::profiles::jenkins::buildtools

  $default_file_attributes = {
    require => Package['jenkins-swarm-client'],
    notify  => Service['jenkins-swarm-client']
  }

  realize Group['jenkins']
  realize User['jenkins']

  realize Profiles::Apt::Update['publiq-jenkins']

  package { 'jenkins-swarm-client':
    ensure  => $version,
    require => Profiles::Apt::Update['publiq-jenkins'],
    notify  => Service['jenkins-swarm-client']
  }

  file { 'jenkins-swarm-client_fsroot':
    ensure => 'directory',
    path   => '/var/lib/jenkins-swarm-client',
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0755',
    *      => $default_file_attributes
  }

  file { 'jenkins-swarm-client_passwordfile':
    ensure  => 'file',
    path    => '/etc/jenkins-swarm-client/password',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
    content => $password,
    *      => $default_file_attributes
  }

  file { 'jenkins-swarm-client_node-labels':
    ensure  => 'file',
    path    => '/etc/jenkins-swarm-client/node-labels.conf',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    content => [concat([$facts['lsbdistcodename']], $labels)].flatten.join("\n"),
    *      => $default_file_attributes
  }

  file { 'jenkins-swarm-client_service-defaults':
    ensure  => 'file',
    path    => '/etc/default/jenkins-swarm-client',
    mode    => '0644',
    content => template('profiles/jenkins/jenkins-swarm-client_service-defaults.erb'),
    *      => $default_file_attributes
  }

  service { 'jenkins-swarm-client':
    ensure  => 'running',
    enable  => 'true',
    require => [Group['jenkins'], User['jenkins'], Class['profiles::java']]
  }
}
