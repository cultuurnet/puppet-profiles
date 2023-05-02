class profiles::timezone (
  String $region   = 'Etc',
  String $locality = 'UTC'

) inherits ::profiles {

  class { '::timezone':
    region   => $region,
    locality => $locality
  }
}
