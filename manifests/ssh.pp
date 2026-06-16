class profiles::ssh(
  Variant[Hash, Array[Hash]]     $authorized_keys      = {},
  Variant[String, Array[String]] $authorized_keys_tags = [],
  Boolean                        $mfa                  = false,
  Boolean                        $manage_admin_user_authorized_keys = true,
  Boolean                        $mfa_enforced         = false
) inherits ::profiles {

  include ::profiles::firewall::rules
  include ::profiles::ssh::service

  package { 'openssh-server':
    ensure => 'latest',
    notify => Class['profiles::ssh::service']
  }

  profiles::ssh::sshd_config { 'PermitRootLogin':
    ensure => 'present',
    value  => 'no',
    notify  => Class['profiles::ssh::service']
  }

  profiles::ssh::sshd_config { 'PubkeyAcceptedKeyTypes':
    ensure => 'absent',
    notify  => Class['profiles::ssh::service']
  }

  file { '/etc/ssh/sshd_config.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  profiles::ssh::sshd_config { 'Include':
    value  => '/etc/ssh/sshd_config.d/*.conf',
    notify => Class['profiles::ssh::service']
  }

  file { 'ssh_known_hosts':
    ensure => 'file',
    path   => '/etc/ssh/ssh_known_hosts',
    mode   => '0644'
  }

  if $settings::storeconfigs {
    @@sshkey { "${facts['networking']['hostname']}@ssh-rsa":
      key          => $facts['ssh']['rsa']['key'],
      host_aliases => [$facts['networking']['ip'], $facts['networking']['fqdn']]
    }

    Sshkey <<| |>>
  }

  resources { 'sshkey':
    purge => true
  }

  resources { 'ssh_authorized_key':
    purge => true
  }

  class { 'profiles::ssh::authorized_keys':
    keys                              => $authorized_keys,
    manage_admin_user_authorized_keys => $manage_admin_user_authorized_keys
  }

  class { 'profiles::ssh::mfa':
    enabled              => $mfa,
    enforced             => $mfa_enforced,
    authorized_keys      => $authorized_keys,
    authorized_keys_tags => $authorized_keys_tags
  }

  Class['profiles::ssh::mfa'] ~> Class['profiles::ssh::service']

  [$authorized_keys_tags].flatten.each |$tag| {
    Ssh_authorized_key <| tag == $tag |>
  }

  Ssh_authorized_key <<| tag == 'jenkins' |>>

  realize Firewall['100 accept SSH traffic']
}
