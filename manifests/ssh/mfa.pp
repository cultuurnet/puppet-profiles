class profiles::ssh::mfa (
  Boolean                        $enabled              = false,
  Variant[Hash, Array[Hash]]     $authorized_keys      = {},
  Variant[String, Array[String]] $authorized_keys_tags = [],
  Array[String]                  $bypass_ips           = ['194.78.13.220'],
  String                         $mfa_directory        = '/etc/puppetlabs/code/data/mfa'
) inherits ::profiles {

  $authorized_keys_tags_array = [$authorized_keys_tags].flatten

  $configured_users = $authorized_keys.filter |String $user, Hash $attributes| {
    $tags = $attributes['tags'] ? {
      undef   => [],
      default => [$attributes['tags']].flatten
    }
    $configured = $tags.any |String $tag| { $tag in $authorized_keys_tags_array }
    $username   = slugify($user)

    $enabled and $configured and $attributes['active'] != false and find_file("${mfa_directory}/${username}.conf")
  }
  $configured_usernames = $configured_users.keys.map |String $user| { slugify($user) }
  $mfa_addresses        = ['*'] + $bypass_ips.map |String $ip| { "!${ip}" }

  if $enabled {
    package { 'libpam-google-authenticator':
      ensure => 'installed'
    }

    file { '/etc/pam.d/sshd':
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('profiles/ssh/mfa/sshd.pam.erb'),
      require => Package['libpam-google-authenticator']
    }

    if !empty($configured_users) {
      file { '/etc/ssh/sshd_config.d/publiq-mfa.conf':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('profiles/ssh/mfa/sshd_config.erb')
      }
    } else {
      file { '/etc/ssh/sshd_config.d/publiq-mfa.conf':
        ensure => 'absent'
      }
    }

    profiles::ssh::sshd_config { 'ChallengeResponseAuthentication':
      value => 'yes'
    }

    $configured_users.each |String $user, Hash $attributes| {
      $username = slugify($user)
      $config   = "${mfa_directory}/${username}.conf"

      file { "/home/${username}/.google_authenticator":
        ensure    => 'file',
        owner     => $username,
        group     => $username,
        mode      => '0400',
        content   => file($config),
        show_diff => false,
        require   => User[$username]
      }
    }
  } else {
    file { '/etc/pam.d/sshd':
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('profiles/ssh/mfa/sshd.pam.erb')
    }

    file { '/etc/ssh/sshd_config.d/publiq-mfa.conf':
      ensure => 'absent'
    }

    profiles::ssh::sshd_config { 'ChallengeResponseAuthentication':
      value => 'no'
    }
  }

  group { 'mfa_users':
    ensure => 'present'
  }

  $authorized_keys.each |String $user, Hash $attributes| {
    $username = slugify($user)
    $groups   = $attributes['admin'] ? {
      true    => ['sudo'],
      default => []
    }

    if $username in $configured_usernames {
      User <| title == $username |> {
        groups => $groups + ['mfa_users']
      }
    } else {
      User <| title == $username |> {
        groups => $groups
      }
    }
  }

  profiles::ssh::sshd_config { 'UsePAM':
    value => 'yes'
  }

  profiles::ssh::sshd_config { 'AuthenticationMethods':
    ensure => 'absent',
    value  => 'publickey,keyboard-interactive:pam'
  }
}
