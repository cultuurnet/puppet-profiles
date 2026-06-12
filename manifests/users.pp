class profiles::users (
  Hash                           $shell      = {},
  Variant[String, Array[String]] $shell_tags = []
) inherits ::profiles {

  include profiles::users::software

  $shell.each |String $user, Hash $attributes| {
    @profiles::users::shell { $user:
      uid    => $attributes['uid'],
      active => $attributes['active'],
      admin  => $attributes['admin'],
      tag    => $attributes['tags']
    }
  }

  [$shell_tags].flatten.each |$tag| {
    Profiles::Users::Shell <| tag == $tag |>
  }
}
