class profiles::ssh(
  Variant[String, Array[String]] $ssh_authorized_keys_tags = []
) {

  contain ::profiles

  include ::profiles::packages
  include ::profiles::firewall
  include ::profiles::ssh_authorized_keys

  Sshd_config {
    require => [ Package['augeas-tools'], Package['ruby-augeas']],
    notify  => Service['ssh']
  }

  realize Package['augeas-tools']
  realize Package['ruby-augeas']

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

  any2array($ssh_authorized_keys_tags).each |$tag| {
    Ssh_authorized_key <| tag == $tag |>
  }

  realize Firewall['100 accept ssh traffic']
}
