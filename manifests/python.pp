class profiles::python (
  String $version = '3.6'
) inherits ::profiles {

  if $version == '3.7' {
    realize Apt::Ppa['ppa:deadsnakes/ppa']

    Apt::Ppa['ppa:deadsnakes/ppa'] -> Package["python${version}"]
  }

  package { "python${version}":
    ensure => 'installed'
  }
}
