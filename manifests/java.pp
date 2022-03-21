class profiles::java (
  Variant[Integer[8, 11], Array[Integer[8, 11]]] $installed_versions = 8,
  Optional[Integer[8, 11]]                       $default_version    = undef
) inherits ::profiles {

  realize Package['fontconfig']

  [$installed_versions].flatten.each | $version | {

    class { "::profiles::java::java${version}":
      before  => Class['profiles::java::alternatives'],
      require => Package['fontconfig']
    }
  }

  class { ::profiles::java::alternatives:
    default_version => $default_version
  }
}
