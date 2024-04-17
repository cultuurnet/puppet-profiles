class profiles::nodejs (
  Optional[String] $version       = undef,
  Integer          $major_version = if $version { Integer(split($version, /\./)[0]) } else { 16 }
) inherits ::profiles {

  if ($version and $major_version) {
    if Integer(split($version, /\./)[0]) != $major_version {
      fail("Profiles::Nodejs: incompatible combination of 'version' and 'major_version' parameters")
    }
  }

  realize Apt::Source["nodejs-${major_version}"]
  realize Apt::Source['publiq-tools']

  realize Package['yarn']

  class { '::nodejs':
    manage_package_repo   => false,
    nodejs_package_ensure => $version,
    require               => Apt::Source["nodejs-${major_version}"],
    before                => Package['yarn']
  }

  # Hack until https://github.com/nodejs/gyp-next/pull/204 is merged and the
  # gyp-next containing the fix is included in nodejs
  # Narrowed down to specific nodejs version that has been tested

  if $version == '18.17.1-1nodesource1' {
    file { '/usr/lib/node_modules/npm/node_modules/node-gyp/gyp/pylib/gyp/generator/make.py':
      ensure  => 'file',
      source  => 'puppet:///modules/profiles/nodejs/make.py',
      require => Class['nodejs']
    }
  }

}
