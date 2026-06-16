class profiles::users (
  Hash                           $shell      = {},
  Variant[String, Array[String]] $shell_tags = []
) inherits ::profiles {

  include profiles::users::software

  $shell_tags_array = [$shell_tags].flatten

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

    $tags = $attributes['tags'] ? {
      undef   => [],
      default => [$attributes['tags']].flatten
    }

    $configured = $tags.any |String $tag| { $tag in $shell_tags_array }

    if !$configured {
      Profiles::Users::Shell <| title == $user |> {
        active => false
      }
    }
  }

  $shell_tags_array.each |$tag| {
    Profiles::Users::Shell <| tag == $tag |>
  }
}
