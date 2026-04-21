class profiles::terraform (
  String $version = 'latest'
) inherits ::profiles {

  realize Apt::Source['hashicorp']

  package { 'terraform':
    ensure  => $version,
    require => Apt::Source['hashicorp']
  }

  @profiles::jenkins::node_labels { 'terraform':
    content => 'terraform'
  }
}
