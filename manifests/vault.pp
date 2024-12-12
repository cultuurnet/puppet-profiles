class profiles::vault (
  String $version = 'latest'
) inherits ::profiles {

  realize Apt::Source['hashicorp']
  realize Group['vault']
  realize User['vault']

  package { 'vault':
    ensure  => $version,
    require => [Group['vault'], User['vault'], Apt::Source['hashicorp']]
  }
}
