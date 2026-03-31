class profiles::aws_cli inherits ::profiles {

  realize Apt::Source['publiq-tools']
  realize Package['awscli']

  package { 'aws-cli':
    ensure  => 'absent'
  }
}
