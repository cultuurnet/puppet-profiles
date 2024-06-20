class profiles::ssh(
  Variant[String, Array[String]] $ssh_authorized_keys_tags = []
) inherits ::profiles {

  include ::profiles::firewall::rules
  include ::profiles::ssh_authorized_keys

  Sshd_config {
    notify  => Service['ssh']
  }

  sshd_config { 'PermitRootLogin':
    ensure => 'present',
    value  => 'no'
  }

  if versioncmp( $facts['os']['release']['major'], '16.04') >= 0 {
    sshd_config { 'PubkeyAcceptedKeyTypes':
      ensure => 'present',
      value  => '+rsa-sha2-256,rsa-sha2-512'
    }
  } else {
    sshd_config { 'PubkeyAcceptedKeyTypes':
      ensure => 'absent'
    }
  }

  sshd_config { 'Ciphers':
    ensure => 'present',
    value  => 'aes256-gcm@openssh.com'
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
      host_aliases => [ $facts['networking']['ip'], "${facts['networking']['hostname']}.machines.publiq.be", $facts['networking']['fqdn']]
    }

    Sshkey <<| |>>
  }

  resources { 'sshkey':
    purge => true
  }

  resources { 'ssh_authorized_key':
    purge => true
  }

  any2array($ssh_authorized_keys_tags).each |$tag| {
    Ssh_authorized_key <| tag == $tag |>
  }

  realize Firewall['100 accept SSH traffic']
}
