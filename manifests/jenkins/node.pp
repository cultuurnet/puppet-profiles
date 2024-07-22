class profiles::jenkins::node(
  String                         $version        = 'latest',
  String                         $user           = 'admin',
  String                         $password       = lookup('profiles::jenkins::controller::admin_password', String, 'first', ''),
  String                         $controller_url = lookup('profiles::jenkins::controller::url', String, 'first', 'http://localhost:8080/'),
  Boolean                        $lvm            = false,
  Optional[String]               $volume_group   = undef,
  Optional[String]               $volume_size    = undef,
  Integer                        $executors      = 1,
  Variant[String, Array[String]] $labels         = []

) inherits ::profiles {

  include ::profiles::java
  include ::profiles::jenkins::buildtools
  include ::profiles::jenkins::buildtools::playwright

  $default_file_attributes = {
                               require => Package['jenkins-swarm-client'],
                               notify  => Service['jenkins-swarm-client']
                             }
  $default_labels          = [
                               $facts['os']['name'],
                               $facts['os']['release']['major'],
                               $facts['os']['distro']['codename']
                             ]

  realize Group['jenkins']
  realize User['jenkins']

  realize Apt::Source['publiq-jenkins']

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'jenkins-node':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/jenkins',
      fs_type      => 'ext4',
      owner        => 'jenkins',
      group        => 'jenkins',
      require      => [Group['jenkins'], User['jenkins']]
    }

    file { 'jenkins-swarm-client_fsroot':
      ensure  => 'link',
      path    => '/var/lib/jenkins-swarm-client',
      target  => '/data/jenkins',
      force   => true,
      owner   => 'jenkins',
      group   => 'jenkins',
      require => Profiles::Lvm::Mount['jenkins-node'],
      before  => Package['jenkins-swarm-client'],
      notify  => Service['jenkins-swarm-client']
    }
  } else {
    file { 'jenkins-swarm-client_fsroot':
      ensure => 'directory',
      path   => '/var/lib/jenkins-swarm-client',
      owner  => 'jenkins',
      group  => 'jenkins',
      mode   => '0755',
      *      => $default_file_attributes
    }
  }

  package { 'jenkins-swarm-client':
    ensure  => $version,
    require => Apt::Source['publiq-jenkins'],
    notify  => Service['jenkins-swarm-client']
  }

  file { 'jenkins-swarm-client_passwordfile':
    ensure  => 'file',
    path    => '/etc/jenkins-swarm-client/password',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
    content => $password,
    *       => $default_file_attributes
  }

  file { 'jenkins-swarm-client_node-labels':
    ensure  => 'file',
    path    => '/etc/jenkins-swarm-client/node-labels.conf',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    content => [concat($default_labels, $labels)].flatten.join("\n").downcase,
    *       => $default_file_attributes
  }

  file { 'jenkins-swarm-client_service-defaults':
    ensure  => 'file',
    path    => '/etc/default/jenkins-swarm-client',
    mode    => '0644',
    content => template('profiles/jenkins/jenkins-swarm-client_service-defaults.erb'),
    *       => $default_file_attributes
  }

  service { 'jenkins-swarm-client':
    ensure  => 'running',
    enable  => 'true',
    require => [Group['jenkins'], User['jenkins'], Class['profiles::java']]
  }
}
