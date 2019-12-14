class profiles::ssh(
  Variant[String, Array[String]] $ssh_authorized_keys_tags = []
) {

  contain ::profiles

  include ::profiles::firewall
  include ::profiles::ssh_authorized_keys

  Sshd_config {
    notify => Service['ssh']
  }

  sshd_config { 'PermitRootLogin':
    ensure => 'present',
    value  => 'no'
  }

  service { 'ssh':
    ensure => 'running',
    enable => true
  }

  resources { 'ssh_authorized_key':
    purge => true
  }

  $ssh_authorized_keys_tags.each |$tag| {
    Ssh_authorized_key <| tag == $tag |>
  }

  realize Firewall['100 accept ssh traffic']
}
