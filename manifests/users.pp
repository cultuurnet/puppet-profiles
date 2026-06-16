class profiles::users (
  Hash                           $shell      = {},
  Variant[String, Array[String]] $shell_tags = []
) inherits ::profiles {

  include profiles::users::software

  $shell.each |String $user, Hash $attributes| {
    $mfa = $attributes['mfa'] ? {
      undef   => true,
      default => $attributes['mfa']
    }
    $mfa_config = $attributes['mfa_config'] ? {
      undef   => undef,
      default => $attributes['mfa_config']
    }

    @profiles::users::shell { $user:
      uid        => $attributes['uid'],
      active     => $attributes['active'],
      admin      => $attributes['admin'],
      mfa        => $mfa,
      mfa_config => $mfa_config,
      tag        => $attributes['tags']
    }
  }

  [$shell_tags].flatten.each |$tag| {
    Profiles::Users::Shell <| tag == $tag |>
  }
}
