class profiles::jenkins::node (
  String                         $version        = 'latest',
  String                         $user           = 'admin',
  String                         $password       = lookup('profiles::jenkins::controller::admin_password', String, 'first', ''),
  String                         $controller_url = lookup('profiles::jenkins::controller::url', String, 'first', 'http://localhost:8080/'),
  Boolean                        $bootstrap      = false,
  Boolean                        $lvm            = false,
  Optional[String]               $volume_group   = undef,
  Optional[String]               $volume_size    = undef,
  Integer                        $executors      = 1,
  Variant[String, Array[String]] $labels         = []
) inherits ::profiles {

  include ::profiles::java
  include ::profiles::jenkins::buildtools::bootstrap

  unless $bootstrap {
    include ::profiles::jenkins::buildtools::homebuilt
    include ::profiles::jenkins::buildtools::playwright

    profiles::puppet::puppetdb::cli { 'jenkins': }
  }

  $puppetserver_url = lookup('data::puppet::puppetserver::url')
  $data_dir         = '/var/lib/jenkins-swarm-client'
  $default_labels   = [
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

    profiles::lvm::mount { 'jenkinsdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/jenkins',
      fs_type      => 'ext4',
      owner        => 'jenkins',
      group        => 'jenkins',
      require      => [Group['jenkins'], User['jenkins']]
    }

    mount { $data_dir:
      ensure  => 'mounted',
      device  => '/data/jenkins',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['jenkinsdata'], File[$data_dir]],
      before  => Package['jenkins-swarm-client'],
      notify  => Service['jenkins-swarm-client']
    }
  }

  @@profiles::vault::trusted_certificate { $trusted['certname']:
    policies => ['jenkins_certificate']
  }

  file { $data_dir:
    ensure => 'directory',
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0755',
    before => Package['jenkins-swarm-client'],
    notify => Service['jenkins-swarm-client']
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
    require => Package['jenkins-swarm-client'],
    notify  => Service['jenkins-swarm-client']
  }

  file { 'jenkins-swarm-client_node-labels':
    ensure  => 'file',
    path    => '/etc/jenkins-swarm-client/node-labels.conf',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    content => [concat($default_labels, $labels)].flatten.join("\n").downcase,
    require => Package['jenkins-swarm-client'],
    notify  => Service['jenkins-swarm-client']
  }

  file { 'jenkins-swarm-client_service-defaults':
    ensure  => 'file',
    path    => '/etc/default/jenkins-swarm-client',
    mode    => '0644',
    content => template('profiles/jenkins/jenkins-swarm-client_service-defaults.erb'),
    require => Package['jenkins-swarm-client'],
    notify  => Service['jenkins-swarm-client']
  }

  file { 'jenkins-node-cleanup-script':
    ensure  => 'file',
    path    => '/usr/local/bin/node-cleanup.sh',
    mode    => '0644',
    content => template('profiles/jenkins/jenkins-node-cleanup-script.erb'),
  }

  service { 'jenkins-swarm-client':
    ensure    => 'running',
    enable    => 'true',
    require   => [Group['jenkins'], User['jenkins']],
    subscribe => Class['profiles::java']
  }
}
