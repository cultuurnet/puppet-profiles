class profiles::ssh(
  Variant[String, Array[String]] $ssh_authorized_keys_tags = []
) {

  contain ::profiles

  include ::profiles::firewall
  include ::profiles::ssh_authorized_keys

  Sshd_config {
    notify  => Service['ssh']
  }

  sshd_config { 'PermitRootLogin':
    ensure => 'present',
    value  => 'no'
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
    @@sshkey { fact('network.hostname'):
      type         => 'rsa',
      key          => fact('ssh.rsa.key'),
      host_aliases => [ fact('network.ip'), "${fact('network.hostname')}.machines.publiq.be", fact('network.fqdn')]
    }
  }

  resources { 'sshkey':
    purge => true
  }

  Sshkey <<| |>>

  resources { 'ssh_authorized_key':
    purge => true
  }

  any2array($ssh_authorized_keys_tags).each |$tag| {
    Ssh_authorized_key <| tag == $tag |>
  }

  realize Firewall['100 accept ssh traffic']
}
