class profiles::timezone (
  String $region   = 'Etc',
  String $locality = 'UTC'

) inherits ::profiles {

  class { '::timezone':
    timezone => "${region}/${locality}",
    hwutc    => true
  }
}
