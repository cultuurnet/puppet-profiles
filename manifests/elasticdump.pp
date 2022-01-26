class profiles::elasticdump inherits ::profiles {

  include ::profiles::nodejs

  realize Apt::Source['cultuurnet-tools']

  package { 'elasticdump':
    require => [ Apt::Source['cultuurnet-tools'], Class['profiles::nodejs']]
  }
}
