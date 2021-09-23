class profiles::java (
  Variant[Integer[8, 11], Array[Integer[8, 11]]] $installed_versions = 8,
  Optional[Integer[8, 11]]                       $default_version = undef
) inherits profiles {

  [$installed_versions].flatten.each | $version | {

    class { "::profiles::java::java${version}":
      before => Class['profiles::java::alternatives']
    }
  }

  class { ::profiles::java::alternatives:
    default_version => $default_version
  }
}
