class profiles::ssh(
  Variant[String, Array[String]] $ssh_authorized_keys_tags = []
) inherits ::profiles {

  include ::profiles::firewall::rules
  include ::profiles::ssh_authorized_keys

  Sshd_config {
    notify  => Service['ssh']
  }

  package { 'openssh-server':
    ensure => 'latest',
    notify => Service['ssh']
  }

  sshd_config { 'PermitRootLogin':
    ensure => 'present',
    value  => 'no'
  }

  sshd_config { 'PubkeyAcceptedKeyTypes':
    ensure => 'present',
    value  => '+rsa-sha2-256,rsa-sha2-512'
  }

  service { 'ssh':
    ensure => 'running',
    enable => true
  }

  file { 'ssh_known_hosts':
    ensure => 'file',
    path   => '/etc/ssh/ssh_known_hosts',
    mode   => '0644'
  }

  if $settings::storeconfigs {
    @@sshkey { $facts['networking']['hostname']:
      type         => 'rsa',
      key          => $facts['ssh']['rsa']['key'],
      host_aliases => [ $facts['networking']['ip'], $facts['networking']['fqdn']]
    }

    Sshkey <<| |>>
  }

  resources { 'sshkey':
    purge => true
  }

  resources { 'ssh_authorized_key':
    purge => true
  }

  [$ssh_authorized_keys_tags].flatten.each |$tag| {
    Ssh_authorized_key <| tag == $tag |>
  }

  realize Firewall['100 accept SSH traffic']
}
