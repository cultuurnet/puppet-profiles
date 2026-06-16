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
    $configured  = $tags.any |String $tag| { $tag in $authorized_keys_tags_array }
    $mfa_enabled = $attributes['mfa'] ? {
      undef   => true,
      default => $attributes['mfa']
    }
    $username    = slugify($user)

    $enabled and $configured and $mfa_enabled and $attributes['active'] != false and find_file("${mfa_directory}/${username}.conf") != undef
  }
  $mfa_addresses        = ['*'] + $bypass_ips.map |String $ip| { "!${ip}" }

  file { '/etc/pam.d/sshd':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('profiles/ssh/mfa/sshd.pam.erb')
  }

  if $enabled {
    package { 'libpam-google-authenticator':
      ensure => 'installed',
      before => File['/etc/pam.d/sshd']
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
  } else {
    file { '/etc/ssh/sshd_config.d/publiq-mfa.conf':
      ensure => 'absent'
    }

    profiles::ssh::sshd_config { 'ChallengeResponseAuthentication':
      value => 'no'
    }
  }

  $authorized_keys.each |String $user, Hash $attributes| {
    $tags = $attributes['tags'] ? {
      undef   => [],
      default => [$attributes['tags']].flatten
    }
    $configured  = $tags.any |String $tag| { $tag in $authorized_keys_tags_array }
    $mfa_enabled = $attributes['mfa'] ? {
      undef   => true,
      default => $attributes['mfa']
    }
    $username    = slugify($user)
    $config      = "${mfa_directory}/${username}.conf"
    $mfa         = $enabled and $configured and $mfa_enabled and $attributes['active'] != false and find_file($config) != undef
    $mfa_config = $mfa ? {
      true    => $config,
      default => undef
    }

    Profiles::Users::Shell <| title == $user |> {
      mfa        => $mfa,
      mfa_config => $mfa_config
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
