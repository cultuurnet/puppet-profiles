class profiles::java (
  Variant[Integer[8, 11], Array[Integer[8, 11]]] $installed_versions = 8,
  Optional[Integer[8, 11]]                       $default_version    = undef,
  Enum['jre', 'jdk']                             $distribution       = 'jre',
  Boolean                                        $headless           = true
) inherits ::profiles {

  if $headless {
    $package_name_suffix = '-headless'
  } else {
    $package_name_suffix = ''
  }

  if $default_version {
    $alternatives_version = $default_version
  } else {
    $alternatives_version = [$installed_versions].flatten[0]
  }

  [$installed_versions].flatten.each | $version | {
    package { "openjdk-${version}-${distribution}${package_name_suffix}":
      ensure  => 'installed',
      before  => Class['profiles::java::alternatives'],
    }
  }

  class { ::profiles::java::alternatives:
    default_version => $alternatives_version,
    distribution    => $distribution,
    headless        => $headless
  }
}
