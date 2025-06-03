class profiles::sling (
  String $version           = 'latest',
  Optional[Boolean] $deploy               = false,

) inherits ::profiles {

  realize Apt::Source['publiq-tools']

  if $deploy {
    package { 'sling':
      ensure  => $version,
      require => Apt::Source['publiq-tools']
    }
  }
}
