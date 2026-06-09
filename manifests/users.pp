class profiles::users (
  Hash                           $shell      = {},
  Variant[String, Array[String]] $shell_tags = []
) inherits ::profiles {

  include profiles::users::software

  $shell.each |String $user, Hash $attributes| {
    @profiles::users::shell { $user:
      tag => $attributes['tags'],
      *   => $attributes - 'tags'
    }
  }

  [$shell_tags].flatten.each |$tag| {
    Profiles::Users::Shell <| tag == $tag |>
  }
}
